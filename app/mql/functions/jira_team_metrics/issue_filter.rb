class JiraTeamMetrics::IssueFilter
  def call(ctx, filter_name)
    filter = ctx.board.filters.select{ |f| f.name == filter_name }.first
    if filter.nil?
      []
    else
      ctx.issues.select { |issue| filter.include?(issue) }
    end
  end

  def self.register(ctx)
    ctx.register_function(
      'filter(String)',
      JiraTeamMetrics::IssueFilter.new)
  end
end