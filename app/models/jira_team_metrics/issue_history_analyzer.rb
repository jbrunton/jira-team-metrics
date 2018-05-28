class JiraTeamMetrics::IssueHistoryAnalyzer
  attr_reader :issue

  def initialize(issue)
    @issue = issue
  end

  def history_as_ranges
    issue.transitions.each_cons(2).map do |t1, t2|
      {
          status: t1['toStatus'],
          status_category: t1['toStatusCategory'],
          date_range: JiraTeamMetrics::DateRange.new(
              Time.parse(t1['date']),
              Time.parse(t2['date'])
          )
      }
    end
  end

  def time_in_category(status_category, date_range = nil)
    history_as_ranges
        .select{ |h| h[:status_category] == status_category }
        .map do |h|
      byebug
          if date_range.nil?
            h[:date_range].duration
          else
            h[:date_range].overlap_with(date_range).duration
          end
        end.sum
  end
end