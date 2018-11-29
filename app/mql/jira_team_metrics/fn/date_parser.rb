class JiraTeamMetrics::Fn::DateParser
  def call(_, date_string)
    DateTime.parse(date_string)
  end

  def self.register(ctx)
    ctx.register_function('date(String)', JiraTeamMetrics::Fn::DateParser.new)
  end
end
