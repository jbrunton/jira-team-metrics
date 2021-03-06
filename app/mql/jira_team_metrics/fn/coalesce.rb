class JiraTeamMetrics::Fn::Coalesce
  def call(_, *args)
    args.find{ |arg| !arg.nil? }
  end

  def self.register(ctx)
    ctx.register_function('coalesce(*)', JiraTeamMetrics::Fn::Coalesce.new)
  end
end
