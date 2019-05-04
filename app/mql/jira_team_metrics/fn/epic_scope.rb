class JiraTeamMetrics::Fn::EpicScope
  def initialize(scope_type)
    @scope_type = scope_type
  end

  def call(ctx)
    issue = ctx.table.rows.at(ctx.row_index)
    return nil unless issue.is_epic?

    self.send("#{@scope_type}_scope", issue)
  end

  def self.register(ctx)
    ctx.register_function('actualScope()', JiraTeamMetrics::Fn::EpicScope.new(:actual))
    ctx.register_function('plannedScope()', JiraTeamMetrics::Fn::EpicScope.new(:planned))
  end

  private

  def actual_scope(epic)
    epic.issues(recursive: false).count
  end

  def planned_scope(epic)
    started_time = epic.send(:jira_started_time)
    return nil if started_time.nil?
    
    epic.issues(recursive: false).select { |i| i.started? && i.started_time <= started_time }.count
  end
end
