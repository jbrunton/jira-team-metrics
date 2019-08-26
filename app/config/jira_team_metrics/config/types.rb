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
        "Optional<#{type.describe_type}>"
      end
    end

    class Array < AbstractType
      attr_reader :element_type

      def initialize(element_type)
        @element_type = element_type
      end

      def type_check(value)
        value.is_a?(::Array) && value.all? { |x| element_type.type_check(x) }
      end

      def describe_type
        "Array<#{element_type.describe_type}>"
      end
    end

    class Hash < AbstractType
      attr_reader :schema

      def initialize(schema)
        @schema = schema
      end

      def type_check(value)
        value.is_a?(::Hash) && schema.map { |key, type| type.type_check(value[key]) }.all?
      end
    end
  end
end