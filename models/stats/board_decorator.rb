require 'draper'
require 'descriptive_statistics'

class BoardDecorator < Draper::Decorator
  delegate_all

  def initialize(board, from_state, to_state)
    super(board)
    @from_state = from_state
    @to_state = to_state
  end

  def completed_issues
    @completed_issues ||= object.issues
      .select{ |i| i.completed && i.started }
      .map{ |i| IssueDecorator.new(i, @from_state, @to_state) }
  end

  def cycle_times
    @cycle_times ||= completed_issues.map{ |i| i.cycle_time }.compact
  end

  def max_cycle_time
    @max_cycle_time ||= cycle_times.max
  end

  def mean_cycle_time
    @mean_cycle_time ||= cycle_times.mean
  end

  def median_cycle_time
    @median_cycle_time ||= cycle_times.median
  end

  def stddev_cycle_time
    @stddev_cycle_time ||= cycle_times.standard_deviation
  end

  def get_binding
    binding()
  end

  def pretty_print_date(date)
    date.strftime('%d %b %Y')
  end

  def pretty_print_number(number)
    '%.2fd' % number
  end
end