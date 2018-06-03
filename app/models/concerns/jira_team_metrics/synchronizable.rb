module JiraTeamMetrics::Synchronizable
  extend ActiveSupport::Concern

  included do
    validate :validate_syncing
  end

private
  def validate_syncing
    errors.add(:base, 'Synchronize job in progress, please wait.') if sync_in_progress?
  end
end