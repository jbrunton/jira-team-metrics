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
    @completed_issues ||= begin
      issues = object.issues
        .select{ |i| i.completed && i.started }
        .map{ |i| IssueDecorator.new(i, @from_state, @to_state) }
      IssuesDecorator.new(issues)
    end
  end

  def issues_by_type
    @issues_by_type ||= completed_issues
      .group_by{ |i| i.issue_type }
      .map{ |issue_type, issues| [issue_type, IssuesDecorator.new(issues)] }
      .to_h
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