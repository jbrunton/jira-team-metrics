class JiraTeamMetrics::Epic < Draper::Decorator
  delegate_all

  def scope
    @scope ||= object.issues(recursive: true)
  end

  def forecaster
    @forecaster ||= JiraTeamMetrics::Forecaster.new(scope)
  end
end