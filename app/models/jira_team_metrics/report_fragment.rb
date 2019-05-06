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

  def self.fetch_for(report_key, fragment_key, sync_history_id)
    if sync_history_id.nil?
      JiraTeamMetrics::ReportFragment
        .where(report_key: report_key, fragment_key: fragment_key)
        .order(sync_history_id: :desc)
        .first
    else
      JiraTeamMetrics::ReportFragment
        .find_by(report_key: report_key, fragment_key: fragment_key, sync_history_id: sync_history_id)
    end
  end

  def self.fetch_contents_for(report_key, fragment_key, sync_history_id)
    fragment = fetch_for(report_key, fragment_key, sync_history_id)
    fragment.contents unless fragment.nil?
  end
end
