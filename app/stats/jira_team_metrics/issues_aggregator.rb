class JiraTeamMetrics::IssuesAggregator
  include JiraTeamMetrics::FormattingHelper

  def initialize(issues, date_attr)
    @date_attr = date_attr
    @issues = issues.sort_by{ |i| i.send(@date_attr) }
  end

  def aggregate(group_by = nil, issues = nil)
    if ['month', 'week'].include?(group_by)
      results = []
      from_date = @issues.first.send(@date_attr)

      while from_date < @issues.last.send(@date_attr)
        to_date = next_date(from_date, group_by)
        date_range = from_date...to_date

        issues = issues_in_range(date_range)
        series_label = pretty_print_date_range(date_range, group_by == 'week' ? {show_day: true} : {})
        results << [series_label, aggregate(nil, issues)]

        from_date = to_date
      end

      results
    else
      issues ||= @issues
      issues_by_type = issues
        .group_by{ |i| i.issue_type }
        .map{ |issue_type, issues_of_type| [issue_type, JiraTeamMetrics::IssuesDecorator.new(issues_of_type)] }
        .to_h

      issue_types = issues_by_type.keys.sort_by do |issue_type|
        -(JiraTeamMetrics::BoardDecorator::ISSUE_TYPE_ORDERING.reverse.index(issue_type) || -1)
      end

      issue_types.map do |issue_type|
        JiraTeamMetrics::BoardDecorator::SummaryRow.new(issue_type, issues_by_type[issue_type], @issues)
      end
    end
  end

private
  def next_date(from_date, group_by)
    if group_by == 'month'
      to_date = from_date.next_month.beginning_of_month
    else
      to_date = from_date.next_week.beginning_of_week
    end
    [to_date, @issues.last.send(@date_attr)].min
  end

  def issues_in_range(date_range)
    @issues.select{ |i| date_range.cover?(i.send(@date_attr)) }
  end
end