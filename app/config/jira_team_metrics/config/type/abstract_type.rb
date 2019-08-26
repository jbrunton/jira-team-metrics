module JiraTeamMetrics::Config::Type
  class AbstractType
    def type_check!(value)
      unless type_check(value)
        raise TypeError, "Invalid type: expected #{describe_type} but found #{value.class}"
      end
    end
  end

  class String < AbstractType
    def type_check(value)
      value.is_a?(::String)
    end

    def describe_type
      "String"
    end
  end

  class Boolean < AbstractType
    def type_check(value)
      value.in? [true, false]
    end

    def describe_type
      "Boolean"
    end
  end

  class Integer < AbstractType
    def type_check(value)
      value.is_a?(::Integer)
    end

    def describe_type
      "Integer"
    end
  end

  class Optional < AbstractType
    attr_reader :type

    def initialize(type)
      @type = type
    end

    def type_check!(value)
      value.nil?
    end
  end
end
