class JiraTeamMetrics::ReportFragment < ApplicationRecord
  serialize :contents
  belongs_to :board
  belongs_to :sync_history

  def self.fetch(board, report_key, fragment_key)
    board.report_fragments.find_by(report_key: report_key, fragment_key: fragment_key)
  end

  def self.fetch_contents(board, report_key, fragment_key)
    fragment = fetch(board, report_key, fragment_key)
    fragment.contents unless fragment.nil?
  end
end
