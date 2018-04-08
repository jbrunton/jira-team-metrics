class CfdBuilder
  include ChartsHelper
  include FormattingHelper

  CfdRow = Struct.new(:predicted, :to_do, :in_progress, :done) do
    def to_array(date_string, annotations)
      [date_string, done, annotations, in_progress, to_do, predicted]
    end
  end

  def initialize(scope)
    @scope = scope
  end

  def build(started_date, completion_rate, completion_date, team_completion_dates)
    data = [[{'label' => 'Date', 'type' => 'date', 'role' => 'domain'}, 'Done', {'role' => 'annotation'}, 'In Progress', 'To Do', 'Predicted']]
    dates = DateRange.new(started_date, completion_date).to_a
    dates.each do |date|
      annotations = []

      {'Overall' => completion_date}.merge(team_completion_dates).each do |team, team_completion_date|
        unless team_completion_date.nil?
          if date <= team_completion_date && team_completion_date < date + 1.day
            annotations << "#{team}: #{pretty_print_date(team_completion_date, show_tz: false, hide_year: true)}"
          end
        end
      end

      if annotations.empty?
        annotations = nil
      else
        annotations = annotations.join(' ')
      end

      date_string = date_as_string(date)
      data << cfd_row_for(date, completion_rate).to_array(date_string, annotations)
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