class JiraTeamMetrics::IssueDecorator < Draper::Decorator
  include JiraTeamMetrics::FormattingHelper

  delegate_all

  def initialize(issue, from_state, to_state, date_range)
    super(issue)
    @from_state = from_state
    @to_state = to_state
    @date_range = date_range
  end

  def epic
    object.epic.nil? ? nil : JiraTeamMetrics::IssueDecorator.new(object.epic, @from_date, @to_date, @date_range)
  end

  def started
    @started ||= object.started_time(@from_state)
  end

  def completed
    @completed ||= object.completed_time(@to_state)
  end

  def cycle_time
    @cycle_time ||= object.cycle_time_between(@from_state, @to_state)
  end

  # def duration_in_range
  #   if issue_type == 'Epic'
  #     nil
  #   else
  #     @date_range.nil? ? nil : @date_range.overlap_with(JiraTeamMetrics::DateRange.new(@started, @completed)).duration
  #   end
  # end

  def decorate(_options)
    self
  end
end