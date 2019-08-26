class JiraTeamMetrics::Config
  module Types
    class AbstractType
      def type_check!(value)
        unless type_check(value)
          raise TypeError, "Invalid type: expected #{describe_type} but found #{value.class}"
        end
      end
    end

    class String
      def type_check(value)
        value.is_a?(::String)
      end

      def describe_type
        "String"
      end
    end

    class Boolean
      def type_check(value)
        value.in? [true, false]
      end

      def describe_type
        "Boolean"
      end
    end

    class Integer
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

      def type_check(value)
        value.nil? || type.type_check(value)
      end

      def describe_type
        "Optional(#{type.describe_type})"
      end
    end
  end
end