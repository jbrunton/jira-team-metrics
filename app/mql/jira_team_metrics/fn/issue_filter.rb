class JiraTeamMetrics::Fn::IssueFilter
  def call(ctx, filter_name)
    filter = ctx.board.filters.select{ |f| f.name == filter_name }.first
    if filter.nil?
      raise "Filter #{filter_name} has not been defined."
    else
      filter.include?(ctx.table.rows.at(ctx.row_index))
    end
  end

  def self.register(ctx)
    ctx.register_function(
      'filter(String)',
      JiraTeamMetrics::Fn::IssueFilter.new)
  end
end