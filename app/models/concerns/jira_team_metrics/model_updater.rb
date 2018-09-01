class JiraTeamMetrics::ModelUpdater
  include JiraTeamMetrics::EnvironmentHelper

  def initialize(object)
    @object = object
  end

  def can_update?(target_model = nil)
    target_model ||= @object
    if readonly_mode?
      target_model.errors.add(:base, 'Server started in readonly mode. Config is readonly.')
      false
    else
      can_sync?(target_model)
    end
  end

  def can_sync?(target_model = nil)
    target_model ||= @object
    if @object.domain.syncing?
      target_model.errors.add(:base, 'Synchronize job in progress, please wait.')
      false
    else
      true
    end
  end

  def update(object_params, target_model = nil)
    target_model ||= @object
    can_update?(target_model) && @object.update(object_params)
  end
end