class JiraTeamMetrics::Fn::DataSource
  include JiraTeamMetrics::ProjectsHelper

  def initialize(scope_type)
    @scope_type = scope_type
  end

  def call(ctx, status_category = nil)
    issues = filter_scope(ctx.table.rows)
    if status_category.nil?
      JiraTeamMetrics::Eval::MqlIssuesTable.new(issues)
    else
      JiraTeamMetrics::Eval::MqlIssuesTable.new(issues.select { |issue| issue.status_category == status_category })
    end
  end

  def self.register(ctx)
    projects_function_name = projects_path_plural(ctx.board.domain)
    ctx.register_function('issues()', JiraTeamMetrics::Fn::DataSource.new(:issue))
    ctx.register_function('issues(String)', JiraTeamMetrics::Fn::DataSource.new(:issue))
    ctx.register_function('epics()', JiraTeamMetrics::Fn::DataSource.new(:epic))
    ctx.register_function('epics(String)', JiraTeamMetrics::Fn::DataSource.new(:epic))
    ctx.register_function("#{projects_function_name}()", JiraTeamMetrics::Fn::DataSource.new(:project))
    ctx.register_function("#{projects_function_name}(String)", JiraTeamMetrics::Fn::DataSource.new(:project))
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