require 'draper'

class IssueDecorator < Draper::Decorator
  include FormattingHelper

  delegate_all

  def initialize(issue, from_state, to_state, date_range)
    super(issue)
    @from_state = from_state
    @to_state = to_state
    @date_range = date_range
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

  def duration_in_range
    @date_range.nil? ? nil : @date_range.overlap_with(DateRange.new(@started, @completed)).duration
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
      DataTable::Row.new(['Cycle Time (days)', pretty_print_number(cycle_time)], nil),
      DataTable::Row.new(['Labels', labels.join(', ')], nil)
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