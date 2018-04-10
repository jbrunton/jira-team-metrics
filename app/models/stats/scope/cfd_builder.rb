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

  def initialize(scope)
    @scope = scope
  end

  def build(increment_report, cfd_type)
    case cfd_type
      when :raw
        completion_rate = increment_report.rolling_completion_rate(7)
        completion_date = increment_report.rolling_forecast_completion_date(7)
        team_completion_dates = increment_report.teams.map do |team|
          team_report = increment_report.team_report_for(team)
          team_completion_date = team_report.rolling_forecast_completion_date(7)
          if team_completion_date
            [team, team_completion_date]
          else
            nil
          end
        end.compact.to_h
      when :trained
        completion_rate = increment_report.trained_completion_rate
        completion_date = increment_report.trained_completion_date
        team_completion_dates = increment_report.teams.map do |team|
          team_report = increment_report.team_report_for(team)
          team_completion_date = team_report.trained_completion_date
          if team_completion_date
            [team, team_completion_date]
          else
            nil
          end
        end.compact.to_h
      else
        raise "Unexpected cfd_type: #{cfd_type}"
    end

    data = [[{'label' => 'Date', 'type' => 'date', 'role' => 'domain'}, 'Done', {'role' => 'annotation'}, {'role' => 'annotationText'}, 'In Progress', 'To Do', 'Predicted']]
    dates = DateRange.new(increment_report.started_date, completion_date).to_a
    dates.each do |date|
      annotations = []

      team_completion_dates.each do |team, team_completion_date|
        if date <= team_completion_date && team_completion_date < date + 1.day
          annotations << Domain::SHORT_TEAM_NAMES[team]
        end
      end

      date_string = date_as_string(date)
      if annotations.any?
        annotation = annotations.join(',')
        annotation_text = pretty_print_date(date, show_tz: false, hide_year: true)
      end
      data << cfd_row_for(date, completion_rate).to_array(date_string, annotation, annotation_text)
    end

    data
  end

private
  def cfd_row_for(date, completion_rate)
    row = CfdRow.new(0, 0, 0, 0)

    @scope.each do |issue|
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
      adjust_row_with_predictions(row, date, completion_rate)
    end

    row
  end

  def adjust_row_with_predictions(row, date, completion_rate)
    change = completion_rate * (date - Time.now) / 1.day
    row.done += change

    if row.predicted > 0
      predicted_change = [row.predicted, change].min
      row.predicted -= predicted_change
      change -= predicted_change
    end

    if row.to_do > 0 && change > 0
      to_do_change = [row.to_do, change].min
      row.to_do -= to_do_change
      change -= to_do_change
    end

    if row.in_progress > 0 && change > 0
      row.in_progress -= change
    end
  end
end