class JiraTeamMetrics::IssueLinkerService
  def initialize(board)
    @board = board
    @project_type = board.domain.config.project_type
  end

  def build_graph
    link_epics
    unless @project_type.nil?
      link_parents
      link_projects
    end
  end

private
  def link_epics
    @board.issues.each do |issue|
      epic_key = issue.fields['Epic Link']
      unless epic_key.blank?
        issue.epic_key = epic_key
        issue.epic = @board.issues.find_by(key: epic_key)
        issue.save
      end
    end
  end

  def link_parents
    @board.issues.reload.each do |issue|
      parent_link = parent_link_for(issue)
      unless parent_link.nil?
        parent_key = parent_link['issue']['key']
        issue.parent_key = parent_key
        issue.parent_issue_type = parent_link['issue']['issue_type']
        issue.parent = @board.issues.find_by(key: parent_key)
        issue.save
      end
    end
  end

  def parent_link_for(issue)
    issue.links
      .find{ |link| link['inward_link_type'] == @project_type.inward_link_type }
  end

  def link_projects
    @board.issues.reload.each do |issue|
      project_key = project_key_for(issue)
      project_key ||= project_key_for(issue.epic) unless issue.epic.nil?
      unless project_key.blank?
        issue.project_key = project_key
        issue.project = @board.issues.find_by(key: project_key)
        issue.save
      end
    end
  end

  def project_key_for(issue, checked_keys = [])
    return nil if issue.parent_key.nil?

    return issue.parent_key if issue.parent_issue_type == @project_type.issue_type

    unless issue.parent.nil? || checked_keys.include?(issue.key)
      project_key_for(issue.parent, checked_keys + [issue.key])
    end
  end
end
