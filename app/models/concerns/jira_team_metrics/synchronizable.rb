module JiraTeamMetrics::Synchronizable
  extend ActiveSupport::Concern

  def validate_syncing(target_model = nil)
    target_model ||= self
    if sync_in_progress?
      target_model.errors.add(:base, 'Synchronize job in progress, please wait.') if sync_in_progress?
      false
    else
      true
    end
  end
end