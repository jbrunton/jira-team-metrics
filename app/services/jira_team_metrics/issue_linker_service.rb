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
    @board.issues.each do |issue|
      parent_key = find_parent_key(issue)
      unless parent_key.blank?
        issue.parent_key = parent_key
        issue.parent = @board.issues.find_by(key: parent_key)
        issue.save
      end
    end
  end

  def find_parent_key(issue)
    parent_link = issue.links
      .find{ |link| link['inward_link_type'] == @project_type.inward_link_type }

    parent_link['issue']['key'] unless parent_link.nil?
  end

  def link_projects
    @board.issues.each do |issue|
      project_key = find_project_key(issue)
      project_key ||= find_project_key(issue.epic) unless issue.epic.nil?
      unless project_key.blank?
        issue.project_key = project_key
        issue.project = @board.issues.find_by(key: project_key)
        issue.save
      end
    end
  end

  def find_project_key(issue)
    return nil if issue.parent.nil?

    candidates = []
    candidate = issue.parent
    while candidate.issue_type != @project_type.issue_type
      candidates.push(candidate)
      candidate = candidate.parent

      break if candidate.nil? || candidates.include?(candidate)
    end

    candidate.try(:key)
  end
end
