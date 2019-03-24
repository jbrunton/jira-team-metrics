class JiraTeamMetrics::Fn::DateDiff
  def call(_, date1, date2, units)
    (date2.to_date - date1.to_date).to_f
  end

  def self.register(ctx)
    ctx.register_function('datediff(Object, Object, Object)', JiraTeamMetrics::Fn::DateDiff.new)
  end
end