class JiraTeamMetrics::IssueSyncService
  def initialize(board, credentials, notifier)
    @board = board
    @credentials = credentials
    @notifier = notifier
  end

  def sync_issues(months_to_sync)
    @notifier.notify_status('fetching issues from JIRA')
    issues = fetch_issues_for_query(@board.sync_query(months_to_sync), 'fetching issues from JIRA')

    @notifier.notify_status('updating cache')
    issues.each do |i|
      @board.issues.create(i)
    end
  end

  def sync_epics
    epic_keys = @board.issues
      .select { |issue| !issue.fields['Epic Link'].nil? && issue.epic.nil? }
      .map { |issue| issue.fields['Epic Link'] }
      .uniq

    if epic_keys.length > 0
      epics = fetch_issues_for_query("key in (#{epic_keys.join(',')})", 'fetching epics from JIRA')
      epics.each do |i|
        @board.issues.create(i)
      end
    end
  end

  private

  def fetch_issues_for_query(query, status)
    client = JiraTeamMetrics::JiraClient.new(@board.domain.config.url, @credentials)
    JiraTeamMetrics::HttpErrorHandler.new(@notifier).invoke do
      client.search_issues(@board.domain, query: query) do |progress|
        @notifier.notify_progress(status + ' (' + progress.to_s + '%)', progress)
      end
    end
  end
end