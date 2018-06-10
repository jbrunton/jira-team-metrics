class JiraTeamMetrics::IssueHistoryAnalyzer
  attr_reader :issue

  def initialize(issue)
    @issue = issue
  end

  def history_as_ranges
    issue.transitions.each_cons(2).map do |t1, t2|
      date_range = JiraTeamMetrics::DateRange.new(
        DateTime.parse(t1['date']),
        DateTime.parse(t2['date'])
      )
      StatusHistory.new(
        t1['toStatus'],
        t1['toStatusCategory'],
        date_range
      )
    end
  end

  def time_in_category(status_category, date_range = nil)
    durations = history_as_ranges
        .select{ |h| h[:status_category] == status_category }
        .map { |h| h.time_in_range(date_range) }

    if durations.empty?
      0
    else
      durations.sum
    end
  end

  StatusHistory = Struct.new(:status, :status_category, :date_range) do
    def time_in_range(date_range)
      if date_range.nil?
        self.date_range.duration
      else
        self.date_range.overlap_with(date_range).duration
      end
    end
  end
end