class JiraTeamMetrics::Config::Types::AbstractType
  def type_check!(value)
    unless type_check(value)
      raise TypeError, "Invalid type: expected #{describe_type} but found #{value.class}"
    end
  end
end
