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

    if epic_keys.length > 0
      batch_count = (epic_keys.length.to_f / EPIC_SLICE_SIZE).ceil
      epic_keys.each_slice(EPIC_SLICE_SIZE).each_with_index do |slice_keys, batch_index|
        message = "fetching epics from JIRA (batch #{batch_index + 1} of #{batch_count})"
        epics = fetch_issues_for_query("key in (#{slice_keys.join(',')})", message)
        epics.each { |epic_attrs| @board.issues.create(epic_attrs) }
      end
    end
  end

  def sync_projects
    linker_service = JiraTeamMetrics::IssueLinkerService.new(@board, @notifier)
    project_keys = @board.issues
      .map{ |issue| [issue, linker_service.parent_link_for(issue)] }
      .select { |issue, project_link| !project_link.nil? && issue.project.nil? }
      .map { |_, project_link| project_link.dig('issue', 'key') }
      .uniq

    project_keys.each{ |key| puts "Missing project: #{key}" }

    if project_keys.length > 0
      batch_count = (project_keys.length.to_f / EPIC_SLICE_SIZE).ceil
      project_keys.each_slice(EPIC_SLICE_SIZE).each_with_index do |slice_keys, batch_index|
        message = "fetching projects from JIRA (batch #{batch_index + 1} of #{batch_count})"
        projects = fetch_issues_for_query("key in (#{slice_keys.join(',')})", message)
        projects.each do |epic_attrs|
          @board.issues.create(epic_attrs)
        end
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