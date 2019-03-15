class JiraTeamMetrics::IssueSyncService
  # to keep urls below 2000 chars. Assuming:
  #   - up to 130 chars for the url prefix and other query params
  #   - up to 10 chars for the Jira key for each epic
  #   - 11 chars required per epic key (including comma separator)
  # then number of epics = (2000 - 130) / 11 = 170
  EPIC_SLICE_SIZE = 170

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

    fetch_issues_by_key(epic_keys, "fetching epics from Jira")
  end

  def sync_projects
    linker_service = JiraTeamMetrics::IssueLinkerService.new(@board, @notifier)
    project_keys = @board.issues
      .map{ |issue| [issue, linker_service.parent_link_for(issue)] }
      .select { |issue, parent_link| !parent_link.nil? && issue.parent.nil? }
      .map { |_, parent_link| parent_link.dig('issue', 'key') }
      .uniq

    fetch_issues_by_key(project_keys, "fetching projects from Jira")
  end

  private

  def fetch_issues_by_key(keys, description)
    return if keys.empty?
    batch_count = (keys.length.to_f / EPIC_SLICE_SIZE).ceil
    keys.each_slice(EPIC_SLICE_SIZE).each_with_index do |slice_keys, batch_index|
      message = "#{description} (batch #{batch_index + 1} of #{batch_count})"
      issues = fetch_issues_for_query("key in (#{slice_keys.join(',')})", message)
      issues.each do |issue_attrs|
        @board.issues.create(issue_attrs)
      end
    end
  end

  def fetch_issues_for_query(query, status)
    client = JiraTeamMetrics::JiraClient.new(@board.domain.config.url, @credentials)
    JiraTeamMetrics::HttpErrorHandler.new(@notifier).invoke do
      client.search_issues(@board.domain, query: query) do |progress|
        @notifier.notify_progress(status + ' (' + progress.to_s + '%)', progress)
      end
    end
  end
end