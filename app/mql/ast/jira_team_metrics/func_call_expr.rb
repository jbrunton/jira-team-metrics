class JiraTeamMetrics::FuncCallExpr
  def initialize(func_name, params)
    @func_name = func_name
    @params = params
  end

  def eval(ctx)
    args = @params.map{ |param| param.eval(ctx.copy(:none)) }
    func = ctx.lookup_function(@func_name, args)
    func.call(ctx, *args)
  end
private
  FUNCTIONS = {
    'today()' => lambda { |_| DateTime.now().to_date },
    'date(String)' => lambda { |_, date_string| DateTime.parse(date_string) },
    # note: values may be either Integer or Fixnum depending on platform
    'date(Object, Object, Object)' => lambda { |_, year, month, day| DateTime.new(year, month, day) },
    'has(JiraTeamMetrics::FieldExpr::ComparisonContext)' => lambda do |_, value|
      value.not_null
    end,
    'filter(String)' => lambda do |ctx, filter_name|
      filter = ctx.board.filters.select{ |f| f.name == filter_name }.first
      if filter.nil?
        []
      else
        ctx.issues.select { |issue| filter.include?(issue) }
      end
    end,
    'issues()' => JiraTeamMetrics::DataSource.new(:issue),
    'issues(String)' => JiraTeamMetrics::DataSource.new(:issue),
    'epics()' => JiraTeamMetrics::DataSource.new(:epic),
    'epics(String)' => JiraTeamMetrics::DataSource.new(:epic),
    'projects()' => JiraTeamMetrics::DataSource.new(:project),
    'projects(String)' => JiraTeamMetrics::DataSource.new(:project)
  }
end