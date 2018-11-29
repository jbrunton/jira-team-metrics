class JiraTeamMetrics::DataSource
  def initialize(scope_type)
    @scope_type = scope_type
  end

  def call(ctx, status_category = nil)
    issues = filter_scope(ctx.issues)
    if status_category.nil?
      issues
    else
      issues.select { |issue| issue.status_category == status_category }
    end
  end

  private

  def filter_scope(issues)
    case @scope_type
      when :project
        issues.select{ |issue| issue.is_project? }
      when :epic
        issues.select{ |issue| issue.is_epic? }
      else
        issues
    end
  end

end