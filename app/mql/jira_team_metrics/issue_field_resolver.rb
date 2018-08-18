class JiraTeamMetrics::IssueFieldResolver
  def initialize(issue)
    @issue = issue
  end

  def resolve(field_name)
    object_field(field_name) ||
      project_key(field_name) ||
      epic_key(field_name) ||
      jira_field(field_name)
  end

private
  def object_field(field_name)
    @issue.send(OBJECT_FIELDS[field_name]) if OBJECT_FIELDS.keys.include?(field_name)
  end

  def jira_field(field_name)
    @issue.fields[field_name] unless @issue.fields[field_name].nil?
  end

  def project_key(field_name)
    @issue.project.try(:key) if field_name == 'project'
  end

  def epic_key(field_name)
    @issue.epic.try('key') if field_name == 'epic'
  end

  OBJECT_FIELDS = {
    'key' => 'key',
    'issuetype' => 'issue_type',
    'summary' => 'summary',
    'status' => 'status',
    'statusCategory' => 'status_category',
    'hierarchyLevel' => 'hierarchy_level',
    'startedTime' => 'started_time',
    'completedTime' => 'completed_time',
    'labels' => 'labels'
  }
end