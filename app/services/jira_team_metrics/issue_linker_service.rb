class JiraTeamMetrics::IssueLinkerService
  def initialize(board)
    @board = board
  end

  def build_graph
    link_epics
    link_parents
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
    project_type = @board.domain.config.project_type
    return if project_type.nil?

    @board.issues.each do |issue|
      parent_key = find_parent_key(issue, project_type)
      unless parent_key.blank?
        issue.parent_key = parent_key
        issue.parent = @board.issues.find_by(key: parent_key)
        issue.save
      end
    end
  end

  def find_parent_key(issue, project_type)
    parent_link = issue.links
      .find{ |link| link['inward_link_type'] == project_type.inward_link_type }

    parent_link['issue']['key'] unless parent_link.nil?
  end
end
