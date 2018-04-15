class BoardDecorator < Draper::Decorator
  include JiraTeamMetrics::FormattingHelper

  ISSUE_TYPE_ORDERING = ['Story', 'Bug', 'Improvement', 'Technical Debt']
  
  delegate_all

  def initialize(board, from_state, to_state, date_range, query = nil)
    super(board)
    @from_state = from_state
    @to_state = to_state
    @date_range = date_range
    if date_range.nil?
      @query = query
    else
      range_query = "between ('#{date_range.start_date.strftime('%Y-%m-%d')}', '#{date_range.end_date.strftime('%Y-%m-%d')}')"
      if query.blank?
        @query = range_query
      else
        @query = "(#{query}) and #{range_query}"
      end
    end
  end

  def issues
    @issues ||= begin
      if @query.blank?
        all_issues
      else
        JiraTeamMetrics::MqlInterpreter.new(all_issues).eval(@query)
      end
    end
  end

  def all_issues
    @all_issues ||= object.issues.map{ |i| IssueDecorator.new(i, @from_state, @to_state, @date_range) }
  end

  def exclusions
    if @exclusions.nil?
      @exclusions = []
      @exclude_filters.each do |filter|
        if filter.config_filter?
          @exclusions.concat(object.exclusions)
        else
          @exclusions.concat(filter.exclusions)
        end
      end
    end
    @exclusions
  end

  def completed_issues
    @completed_issues ||= begin
      issues = self.issues
        .select{ |i| i.completed && i.started }
        .sort_by{ |i| i.completed }
      IssuesDecorator.new(issues)
    end
  end

  # def completed_issues_in_range(date_range)
  #   completed_issues
  #     .select{ |i| date_range.cover?(i.completed) }
  # end

  def issues_by_type
    @issues_by_type ||= completed_issues
      .group_by{ |i| i.issue_type }
      .map{ |issue_type, issues| [issue_type, IssuesDecorator.new(issues)] }
      .sort_by { |issue_type, _| -(ISSUE_TYPE_ORDERING.reverse.index(issue_type) || -1) }
      .to_h
  end

  def issue_types
    issues_by_type.keys
  end

  def wip_history
    dates = object.issues.map{ |issue| [issue.started_time(@from_state), issue.completed_time(@to_state)] }.flatten.compact
    min_date = dates.min.to_date
    max_date = dates.max.to_date

    dates = DateRange.new(min_date, max_date).to_a
    dates.map do |date|
      [date, wip_on_date(date)]
    end
  end

  def wip_on_date(date)
    issues.select do |issue|
      issue.started && issue.started < date &&
        (issue.completed.nil? or issue.completed > date)
    end
  end

  def get_binding
    binding()
  end

  def summarize(group_by = nil)
    IssuesAggregator.new(completed_issues, :completed).aggregate(group_by)
  end

  def summarize_created(group_by = nil)
    IssuesAggregator.new(issues, :issue_created).aggregate(group_by)
  end

  def summary_rows_for(issues)
    summarize(nil, issues).map do |row|
      DataTable::Row.new([
        row.issue_type,
        row.count,
        pretty_print_number(row.count_percentage),
        pretty_print_number(row.ct_mean),
        pretty_print_number(row.ct_median),
        pretty_print_number(row.ct_stddev)
      ], nil)
    end
  end

  def summary_table(group_by = nil)
    rows = [
      DataTable::Header.new(['Issue Type', 'Count', '(%)', 'Cycle Times', '', '']),
      DataTable::Header.new(['', '', '', 'Mean', 'Median', 'Std Dev'])
    ]

    if ['month', 'week'].include?(group_by)
      from_date = completed_issues.first.completed

      while from_date < completed_issues.last.completed
        to_date = next_date(from_date, group_by)
        date_range = from_date...to_date

        heading = pretty_print_date_range(date_range, group_by == 'week' ? {show_day: true} : {})
        rows << DataTable::Header.new([heading, '', '', '', '', ''])

        issues = completed_issues_in_range(date_range)
        rows.concat(summary_rows_for(issues))

        from_date = to_date
      end
    else
      rows.concat(summary_rows_for(completed_issues))

      rows << DataTable::Row.new([
        'ALL',
        completed_issues.count,
        '',
        pretty_print_number(completed_issues.cycle_times.mean),
        pretty_print_number(completed_issues.cycle_times.median),
        pretty_print_number(completed_issues.cycle_times.standard_deviation)
      ], nil)
    end

    DataTable.new(rows)
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

  class SummaryRow
    attr_reader :issue_type

    def initialize(issue_type, select_issues, all_issues)
      @issue_type = issue_type
      @select_issues = select_issues
      @all_issues = all_issues
    end

    def count
      @select_issues.count
    end

    def total_time
      @select_issues.cycle_times.reduce(:+)
    end

    def issue_type_label
      "#{issue_type} (#{count})"
    end

    def count_percentage
      @select_issues.count.to_f / @all_issues.count * 100
    end

    def ct_mean
      @select_issues.cycle_times.mean
    end

    def ct_median
      @select_issues.cycle_times.median
    end

    def ct_stddev
      @select_issues.cycle_times.standard_deviation
    end

    def ct_p10
      @select_issues.cycle_times.percentile(10)
    end

    def ct_p25
      @select_issues.cycle_times.percentile(25)
    end

    def ct_p75
      @select_issues.cycle_times.percentile(75)
    end

    def ct_p90
      @select_issues.cycle_times.percentile(90)
    end

    def ct_min
      @select_issues.cycle_times.min
    end

    def ct_max
      @select_issues.cycle_times.max
    end

    def churn_score
      @select_issues.map{ |issue| churn_metrics_for(issue)[:score] }
    end

    def with_new_label(label)
      SummaryRow.new(label, @select_issues, @all_issues)
    end
  end

private

  # def next_date(from_date, group_by)
  #   if group_by == 'month'
  #     to_date = from_date.next_month.beginning_of_month
  #   else
  #     to_date = from_date.next_week.beginning_of_week
  #   end
  #   [to_date, completed_issues.last.completed].min
  # end
end