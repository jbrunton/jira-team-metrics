class JiraTeamMetrics::IssueLinksService
  def initialize(board)
    @board = board
  end

  def build_graph
    @board.issues.each do |issue|
      epic_key = issue.fields['Epic Link']
      unless epic_key.blank?
        issue.epic_key = epic_key
        issue.epic = @board.issues.find_by(key: epic_key)
        issue.save
      end
    end
  end
end
