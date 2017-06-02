require 'draper'
require 'descriptive_statistics'

class BoardDecorator < Draper::Decorator
  include FormattingHelpers
  
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

  def issue_types
    issues_by_type.keys
  end

  def wip_history
    dates = object.issues.map{ |issue| [issue.started, issue.completed] }.flatten.compact
    min_date = [object.changed_issues_since, dates.min.to_date].max
    max_date = dates.max.to_date

    dates = DateRange.new(min_date, max_date).to_a
    dates.map do |date|
      [date, wip_on_date(date)]
    end
  end

  def wip_on_date(date)
    issues = object.issues.select do |issue|
      issue.started &&
        issue.started < date &&
        (issue.completed.nil? or issue.completed > date)
    end

    issues.map{ |issue| IssueDecorator.new(issue, @from_date, @to_state) }
  end

  def get_binding
    binding()
  end

  def summary_table
    @summary_table ||= begin
      rows = issue_types.map do |issue_type|
        DataTable::Row.new([
          issue_type,
          issues_by_type[issue_type].count,
          pretty_print_number(issues_by_type[issue_type].count.to_f / completed_issues.count * 100),
          pretty_print_number(issues_by_type[issue_type].cycle_times.mean),
          pretty_print_number(issues_by_type[issue_type].cycle_times.median),
          pretty_print_number(issues_by_type[issue_type].cycle_times.standard_deviation)
        ], nil)
      end

      rows << DataTable::Row.new([
        'ALL',
        completed_issues.count,
        '',
        pretty_print_number(completed_issues.cycle_times.mean),
        pretty_print_number(completed_issues.cycle_times.median),
        pretty_print_number(completed_issues.cycle_times.standard_deviation)
      ], nil)


      headers = [
        DataTable::Header.new(['Issue Type', 'Count', '(%)', 'Cycle Times', '', '']),
        DataTable::Header.new(['', '', '', 'Mean', 'Median', 'Std Dev'])
      ]

      DataTable.new(headers + rows)
    end
  end

  def issues_table
    @issues_table ||= begin
      headers = [
        DataTable::Header.new(['Key', 'Issue Type', 'Summary', 'Completed', 'Cycle Time'])
      ]

      rows = completed_issues.map do |issue|
        DataTable::Row.new([
          issue.key,
          issue.issue_type,
          issue.summary,
          pretty_print_date(issue.completed),
          pretty_print_number(issue.cycle_time)
        ], issue)
      end

      DataTable.new(headers + rows)
    end
  end
end