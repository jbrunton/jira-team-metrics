require 'draper'

class IssueDecorator < Draper::Decorator
  include FormattingHelpers

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

  def decorate(_options)
    self
  end

  def overview_table
    rows = [
      DataTable::Row.new(['Key', key], nil),
      DataTable::Row.new(['Summary', summary], nil),
      DataTable::Row.new(['Issue Type', issue_type], nil),
      DataTable::Row.new(['Started', pretty_print_time(started)], nil),
      DataTable::Row.new(['Completed', pretty_print_time(completed)], nil),
      DataTable::Row.new(['Cycle Time (days)', pretty_print_number(cycle_time)], nil)
    ]
    DataTable.new(rows)
  end

  def transitions_table
    rows = transitions.map do |t|
      DataTable::Row.new([
        pretty_print_time(Time.parse(t['date'])),
        "#{t['fromStatus']} -> #{t['toStatus']}"
      ], nil)
    end
    DataTable.new(rows)
  end
end