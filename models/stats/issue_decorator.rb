require 'draper'

class IssueDecorator < Draper::Decorator
  delegate_all

  def initialize(issue, from_state, to_state)
    super(issue)
    @from_state = from_state
    @to_state = to_state
  end

  def started
    @started ||= @from_state ? object.started(@from_state) : issue.started
  end

  def completed
    @completed ||= @to_state ? object.completed(@to_state) : issue.completed
  end

  def cycle_time
    @from_state && @to_state ? object.cycle_time_between(@from_state, @to_state) : issue.cycle_time
  end
end