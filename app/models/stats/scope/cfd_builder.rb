# TODO:
# 1. simulate based on team closure rates
# 2. for teams with zero closure rate, don't add scope

class CfdBuilder
  include ChartsHelper
  include FormattingHelper

  CfdRow = Struct.new(:predicted, :to_do, :in_progress, :done) do
    def to_array(date_string, annotation, annotation_text)
      [date_string, done, annotation, annotation_text, in_progress, to_do, predicted]
    end
  end

  def initialize(increment_report)
    @increment_report = increment_report
  end

  def build(cfd_type)
    lookup_team_completion_rates(cfd_type, @increment_report)

    completion_date = @team_completion_dates.values.compact.max

    data = [[{'label' => 'Date', 'type' => 'date', 'role' => 'domain'}, 'Done', {'role' => 'annotation'}, {'role' => 'annotationText'}, 'In Progress', 'To Do', 'Predicted']]
    dates = DateRange.new(@increment_report.second_percentile_started_date, completion_date).to_a
    dates.each do |date|
      annotation, annotation_text = annotation_for(date)
      data << cfd_row_for(date).to_array(date_as_string(date), annotation, annotation_text)
    end

    data
  end

  def lookup_team_completion_rates(cfd_type, increment_report)
    case cfd_type
      when :raw
        @team_completion_dates = increment_report.teams.map do |team|
          team_report = increment_report.team_report_for(team)
          [team, team_report.rolling_forecast_completion_date(7)]
        end.to_h
        @team_completion_rates = increment_report.teams.map do |team|
          team_report = increment_report.team_report_for(team)
          [team, team_report.rolling_completion_rate(7)]
        end.to_h
      when :trained
        @team_completion_dates = increment_report.teams.map do |team|
          team_report = increment_report.team_report_for(team)
          [team, team_report.trained_completion_date]
        end.to_h
        @team_completion_rates = increment_report.teams.map do |team|
          team_report = increment_report.team_report_for(team)
          [team, team_report.trained_completion_rate]
        end.to_h
      else
        raise "Unexpected cfd_type: #{cfd_type}"
    end
  end

  private
  def cfd_row_for(date)
    row = CfdRow.new(0, 0, 0, 0)

    @increment_report.scope.each do |issue|
      case issue.status_category_on(date)
        when 'To Do'
          row.to_do += 1
        when 'In Progress'
          row.in_progress += 1
        when 'Done'
          row.done += 1
        when 'Predicted'
          row.predicted += 1
      end
    end

    if date > Time.now
      adjust_row_with_predictions(row, date)
    end

    row
  end

  def annotation_for(date)
    annotation = annotation_text = nil
    annotations = []

    @increment_report.teams.each do |team|
      team_completion_date = @team_completion_dates[team]
      unless team_completion_date.nil?
        if date <= team_completion_date && team_completion_date < date + 1.day
          annotations << Domain::SHORT_TEAM_NAMES[team]
        end
      end
    end

    if annotations.any?
      annotation = annotations.join(',')
      annotation_text = pretty_print_date(date, show_tz: false, hide_year: true)
    end

    [annotation, annotation_text]
  end

  def adjust_row_with_predictions(row, date)
    predicted_completion_rate = predicted_rate_on_date(date)

    row.done += predicted_completion_rate

    if row.predicted > 0
      predicted_change = [row.predicted, predicted_completion_rate].min
      row.predicted -= predicted_change
      predicted_completion_rate -= predicted_change
    end

    if row.to_do > 0 && predicted_completion_rate > 0
      to_do_change = [row.to_do, predicted_completion_rate].min
      row.to_do -= to_do_change
      predicted_completion_rate -= to_do_change
    end

    if row.in_progress > 0 && predicted_completion_rate > 0
      row.in_progress -= predicted_completion_rate
    end
  end

  def predicted_rate_on_date(date)
    @increment_report.teams
      .map { |team| predicted_rate_for_team(date, team) }
      .sum
  end

  def predicted_rate_for_team(date, team)
    team_rate = 0

    team_completion_rate = @team_completion_rates[team]
    team_completion_date = @team_completion_dates[team]

    unless team_completion_date.nil?
      team_report = @increment_report.team_report_for(team)
      if date < team_completion_date
        team_rate = team_completion_rate * (date - Time.now) / 1.day
      else
        team_rate = team_report.remaining_scope.count
      end
    end

    team_rate
  end
end