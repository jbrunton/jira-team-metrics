class JiraTeamMetrics::Config::Types::Boolean < JiraTeamMetrics::Config::Types::AbstractType
  def type_check(value)
    value.in? [true, false]
  end

  def describe_type
    "Boolean"
  end
end
