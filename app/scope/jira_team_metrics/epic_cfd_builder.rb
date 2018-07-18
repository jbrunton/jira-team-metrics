class JiraTeamMetrics::EpicCfdBuilder
  include JiraTeamMetrics::FormattingHelper
  include JiraTeamMetrics::ChartsHelper

  CfdRow = Struct.new(:predicted, :to_do, :in_progress, :done) do
    include JiraTeamMetrics::ChartsHelper

    def to_array(date)
      date_string = date_as_string(date)
      [date_string, nil, done, nil, nil, in_progress, to_do, predicted]
    end
  end

  def initialize(epic)
    @epic = epic
  end

  def build
    @issues = @epic.issues(recursive: true)
    today = DateTime.now.to_date
    completion_date = today
    start_date = [@epic.started_time, today - 60].max

    data = [[{'label' => 'Date', 'type' => 'date', 'role' => 'domain'}, {'role' => 'annotation'}, 'Done', {'role' => 'annotation'}, {'role' => 'annotationText'}, 'In Progress', 'To Do', 'Predicted']]
    dates = JiraTeamMetrics::DateRange.new(start_date, completion_date).to_a
    dates.each do |date|
      data << cfd_row_for(date).to_array(date)
    end

    data << [date_as_string(today), 'today', nil, nil, nil, nil, nil, nil]

    data
  end

  private
  def cfd_row_for(date)
    row = CfdRow.new(0, 0, 0, 0)

    @issues.each do |issue|
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
    0
    # @project_report.teams
    #   .map { |team| predicted_rate_for_team(date, team) }
    #   .sum
  end
end