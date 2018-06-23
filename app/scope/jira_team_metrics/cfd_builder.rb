# TODO:
# 1. simulate based on team closure rates
# 2. for teams with zero closure rate, don't add scope

class JiraTeamMetrics::CfdBuilder
  include JiraTeamMetrics::FormattingHelper
  include JiraTeamMetrics::ChartsHelper

  CfdRow = Struct.new(:predicted, :to_do, :in_progress, :done) do
    include JiraTeamMetrics::ChartsHelper

    def to_array(date, annotation, annotation_text)
      date_string = date_as_string(date)
      [date_string, nil, done, annotation, annotation_text, in_progress, to_do, predicted]
    end
  end

  def initialize(increment_report)
    @increment_report = increment_report
  end

  def build(cfd_type)
    lookup_team_completion_rates(cfd_type, @increment_report)

    completion_date = @team_completion_dates.values.compact.max || DateTime.now

    data = [[{'label' => 'Date', 'type' => 'date', 'role' => 'domain'}, {'role' => 'annotation'}, 'Done', {'role' => 'annotation'}, {'role' => 'annotationText'}, 'In Progress', 'To Do', 'Predicted']]
    dates = JiraTeamMetrics::DateRange.new(@increment_report.second_percentile_started_date, completion_date).to_a
    dates.each do |date|
      annotation, annotation_text = annotation_for(date)
      data << cfd_row_for(date).to_array(date, annotation, annotation_text)
    end

    today = DateTime.now.to_date
    data << [date_as_string(today), 'today', nil, nil, nil, nil, nil, nil]
    target_date = @increment_report.increment.target_date
    unless target_date.nil?
      data << [date_as_string(target_date), 'target', nil, nil, nil, nil, nil, nil]
    end

    data
  end

  def lookup_team_completion_rates(cfd_type, increment_report)
    rolling_window_days = increment_report.increment.board.config.rolling_window_days
    case cfd_type
      when :raw
        @team_completion_dates = increment_report.teams.map do |team|
          team_report = increment_report.team_report_for(team)
          [team, team_report.rolling_forecast_completion_date(rolling_window_days)]
        end.to_h
        @team_completion_rates = increment_report.teams.map do |team|
          team_report = increment_report.team_report_for(team)
          [team, team_report.rolling_throughput(rolling_window_days)]
        end.to_h
      when :trained
        @team_completion_dates = increment_report.teams.map do |team|
          team_report = increment_report.team_report_for(team)
          [team, team_report.predicted_completion_date]
        end.to_h
        @team_completion_rates = increment_report.teams.map do |team|
          team_report = increment_report.team_report_for(team)
          [team, team_report.predicted_throughput]
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

    if date > DateTime.now
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
        if date <= team_completion_date && team_completion_date < date + 1
          annotations << JiraTeamMetrics::Domain.get_instance.short_team_name(team)
        end
      end
    end

    if annotations.any?
      annotation = annotations.join(',')
      annotation_text = "#{annotation} - #{pretty_print_date(date, show_tz: false, hide_year: true)}"
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
      row.in_progress -= [row.in_progress, predicted_completion_rate].min
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
        team_rate = team_completion_rate * (date - DateTime.now)
      else
        team_rate = team_report.remaining_scope.count
      end
    end

    team_rate
  end
end