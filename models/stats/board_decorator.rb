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

  def summary_table
    @summary_table ||= begin
      rows = ['Story', 'Bug', 'Improvement', 'Technical Debt'].map do |issue_type|
        [
          issue_type,
          issues_by_type[issue_type].count,
          pretty_print_number(issues_by_type[issue_type].cycle_times.mean),
          pretty_print_number(issues_by_type[issue_type].cycle_times.median),
          pretty_print_number(issues_by_type[issue_type].cycle_times.standard_deviation)
        ]
      end

      headers = [
        ['Issue Type', 'Count', 'Cycle Times', '', ''],
        ['', '', 'Mean', 'Median', 'Std Dev']
      ]

      DataTable.new(headers, rows)
    end
  end

  def issues_table
    @issues_table ||= begin
      headers = [
        ['Key', 'Issue Type', 'Summary', 'Completed', 'Cycle Time']
      ]

      rows = completed_issues.map do |issue|
        [
          { text: issue.key, link_to: issue },
          issue.issue_type,
          issue.summary,
          pretty_print_date(issue.completed),
          pretty_print_number(issue.cycle_time)
        ]
      end

      DataTable.new(headers, rows)
    end
  end
end