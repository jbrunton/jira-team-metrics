class JiraTeamMetrics::IssueFieldResolver
  def initialize(issue)
    @issue = issue
  end

  def resolve(field_name)
    if object_field?(field_name)
      object_field(field_name)
    elsif project_key?(field_name)
      project_key
    elsif epic_key?(field_name)
      epic_key
    elsif jira_field?(field_name)
      jira_field(field_name)
    else
      raise JiraTeamMetrics::ParserError, "Unknown field: #{field_name}"
    end
  end

private
  def object_field?(field_name)
    OBJECT_FIELDS.keys.include?(field_name)
  end

  def object_field(field_name)
    @issue.send(OBJECT_FIELDS[field_name])
  end

  def jira_field?(field_name)
    @issue.board.domain.fields.map{ |it| it['name'] }.include?(field_name)
  end

  def jira_field(field_name)
    @issue.fields.map do |fname, fvalue|
      
    end
  end

  def project_key?(field_name)
    field_name == 'project'
  end

  def project_key
    @issue.project.try(:key)
  end

  def epic_key?(field_name)
    field_name == 'epic'
  end

  def epic_key
    @issue.epic.try('key')
  end

  OBJECT_FIELDS = {
    'key' => 'key',
    'issuetype' => 'issue_type',
    'summary' => 'summary',
    'resolution' => 'resolution',
    'status' => 'status',
    'statuscategory' => 'status_category',
    'hierarchylevel' => 'hierarchy_level',
    'startedtime' => 'started_time',
    'completedtime' => 'completed_time',
    'cycletime' => 'cycle_time',
    'labels' => 'labels',
    'resolution' => 'resolution',
    'global rank' => 'global_rank'
  }
end