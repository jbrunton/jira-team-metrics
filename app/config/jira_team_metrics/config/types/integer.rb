class JiraTeamMetrics::Config::Types::Integer < JiraTeamMetrics::Config::Types::AbstractType
  def type_check(value)
    value.is_a?(::Integer)
  end

  def describe_type
    "Integer"
  end
end
