class JiraTeamMetrics::ScopeCfdBuilder
  include JiraTeamMetrics::FormattingHelper
  include JiraTeamMetrics::ChartsHelper

  CfdRow = Struct.new(:to_do, :in_progress, :done, :predicted) do
    include JiraTeamMetrics::ChartsHelper

    def to_array(date, include_predicted)
      date_string = date_as_string(date)
      total = (done + in_progress + to_do + predicted)
      row = [date_string, nil,
        0, # total displays as zero
        total, # total tooltip
        done,
        in_progress,
        to_do]
      if include_predicted
        row << predicted
      end
      row
    end
  end

  def initialize(scope, rolling_window)
    @scope = scope
    @forecaster = JiraTeamMetrics::Forecaster.new(scope)
    @rolling_window = rolling_window
  end

  def build
    today = DateTime.now.to_date
    forecast_date = @forecaster.forecast(@rolling_window)
    date_range = get_date_range(today, forecast_date)

    data = [build_header]
    dates = JiraTeamMetrics::DateRange.new(date_range.start_date, date_range.end_date).to_a
    dates.each do |date|
      data << cfd_row_for(date).to_array(date, predicted_scope?)
    end

    if @forecaster.remaining_scope.any?
      data << build_annotation(today, 'today')
      data << build_annotation(forecast_date, 'forecast') unless forecast_date.nil?
    end

    data
  end

  def self.build_header(predicted_scope)
    header = [
      {'label' => 'Date', 'type' => 'date', 'role' => 'domain'},
      {'role' => 'annotation'}, # for 'forecast' / 'today' annotations
      'Total',
      {'type' => 'string', 'role' => 'tooltip'}, # annotation for 'Total'
      'Done',
      'In Progress',
      'To Do']
    header << 'Predicted' if predicted_scope
    header
  end

  private
  def get_date_range(today, forecast_date)
    if @forecaster.remaining_scope.any?
      end_date = (forecast_date || DateTime.now) + 2
      start_date = [@forecaster.started_time, today - 60].compact.max
    else
      start_date = @forecaster.started_time - 2
      end_date = @forecaster.completed_time + 2
    end
    JiraTeamMetrics::DateRange.new(start_date, end_date)
  end

  def cfd_row_for(date)
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

    if date > DateTime.now
      adjust_row_with_forecasts(row, date)
    end

    row
  end

  def adjust_row_with_forecasts(row, date)
    adjusted_scope = adjusted_scope_for(date).truncate

    row.done += adjusted_scope

    if row.predicted > 0
      predicted_change = [row.predicted, adjusted_scope].min
      row.predicted -= predicted_change
      adjusted_scope -= predicted_change
    end

    if row.to_do > 0 && adjusted_scope > 0
      to_do_change = [row.to_do, adjusted_scope].min
      row.to_do -= to_do_change
      adjusted_scope -= to_do_change
    end

    if row.in_progress > 0 && adjusted_scope > 0
      row.in_progress -= [row.in_progress, adjusted_scope].min
    end
  end

  def adjusted_scope_for(date)
    forecast = @forecaster.forecast(@rolling_window)
    if forecast.nil?
      0
    else
      if date < forecast
        @forecaster.throughput(@rolling_window) * (date - DateTime.now)
      else
        @forecaster.remaining_scope.count
      end
    end
  end

  def build_header
    JiraTeamMetrics::ScopeCfdBuilder.build_header(predicted_scope?)
  end

  def build_annotation(date, annotation_text)
    padding = Array.new(predicted_scope? ? 6 : 5)
    [date_as_string(date), annotation_text] + padding
  end

  def predicted_scope?
    @predicted_scope ||= @scope.any?{ |issue| issue.status_category == 'Predicted' }
  end
end