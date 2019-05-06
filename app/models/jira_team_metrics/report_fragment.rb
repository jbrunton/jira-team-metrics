class JiraTeamMetrics::ReportFragment < ApplicationRecord
  serialize :contents
  belongs_to :sync_history

  def self.fetch(report_key, fragment_key, sync_history_id = nil)
    if sync_history_id.nil?
      JiraTeamMetrics::ReportFragment
        .where(report_key: report_key, fragment_key: fragment_key)
        .order(created_at: :desc)
        .first
    else
      JiraTeamMetrics::ReportFragment
        .find_by(report_key: report_key, fragment_key: fragment_key, sync_history_id: sync_history_id)
    end
  end

  def self.fetch_contents(report_key, fragment_key, sync_history_id = nil)
    fragment = fetch(report_key, fragment_key, sync_history_id)
    fragment.contents unless fragment.nil?
  end
end
