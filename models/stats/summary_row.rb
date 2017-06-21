class SummaryRow
  attr_reader :issue_type

  def initialize(issues, issue_type)
    @issues = issues
    @issue_type = issue_type
  end

  def count
    @issues.count
  end

  def count_percentage
    @issues.count.to_f / @all_issues.count * 100
  end

  def ct_mean
    @issues.cycle_times.mean
  end

  def ct_median
    @issues.cycle_times.median
  end

  def ct_stddev
    @issues.cycle_times.standard_deviation
  end

private

  def issues
    @issues ||= IssuesDecorator.new(@all_issues.select{ |issue| issue.issue_type == issue_type })
  end

end