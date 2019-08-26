class JiraTeamMetrics::Config::Types::String < JiraTeamMetrics::Config::Types::AbstractType
  def type_check(value)
    value.is_a?(::String)
  end

  def describe_type
    "String"
  end
end
