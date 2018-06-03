class JiraTeamMetrics::UpdateCheck
  include JiraTeamMetrics::EnvironmentHelper

  def initialize(object)
    @object = object
  end

  def can_update?(target_model = nil)
    target_model ||= @object
    if readonly_mode?
      target_model.errors.add(:base, 'Server started in readonly mode. Config is readonly.')
      false
    elsif @object.sync_in_progress?
      target_model.errors.add(:base, 'Synchronize job in progress, please wait.')
      false
    else
      true
    end
  end
end