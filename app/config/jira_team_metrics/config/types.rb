module JiraTeamMetrics::Config
  module Types
    class AbstractType
      def type_check!(value)
        if type_check(value)
          value
        else
          raise TypeError, "Expected #{describe_type} but found #{value.class}"
        end
      end

      def is_like_nil?(value)
        value.nil?
      end
    end

    class String < AbstractType
      def describe_type
        "String"
      end

      def parse(value)
        value
      end

      protected

      def type_check(value)
        value.is_a?(::String)
      end
    end

    class Boolean < AbstractType
      def describe_type
        "Boolean"
      end

      def parse(value)
        value
      end

      protected

      def type_check(value)
        value.in? [true, false]
      end
    end

    class Integer < AbstractType
      def describe_type
        "Integer"
      end

      def parse(value)
        value
      end

      protected

      def type_check(value)
        value.is_a?(::Integer)
      end
    end

    class Optional < AbstractType
      attr_reader :type
      attr_reader :default

      def initialize(type, default = nil)
        type = Hash.new(type) if type.is_a?(::Hash)
        @type = type
        @default = default
      end

      def describe_type
        "Optional<#{type.describe_type}>"
      end

      def parse(value)
        type.parse(value)
      end

      def type_check!(value)
        return if value.nil?
        if type.is_a?(Hash)
          type.type_check!(value, true)
        else
          type.type_check!(value)
        end
      end

      def is_like_nil?(value)
        value.nil? || type.is_like_nil?(value)
      end
    end

    class Array < AbstractType
      attr_reader :element_type

      def initialize(element_type)
        element_type = Hash.new(element_type) if element_type.is_a?(::Hash)
        @element_type = element_type
      end

      def describe_type
        "Array<#{element_type.describe_type}>"
      end

      def parse(value)
        value.map{ |x| element_type.parse(x) }
      end

      def type_check!(value)
        raise TypeError, "Expected Array but found #{value.class}" unless value.is_a?(::Array)
        value.each { |x| element_type.type_check!(x) }
      end

      def is_like_nil?(value)
        value.nil? || value == []
      end
    end

    class Hash < AbstractType
      attr_reader :schema

      def initialize(schema)
        @schema = schema.map do |key, type|
          type = Optional.new(Hash.new(type)) if type.is_a?(::Hash)
          [key, type]
        end.to_h
      end

      def describe_type
        "Hash[#{schema.map{ |key, type| "#{key}: #{type.describe_type}" }.join(', ')}]"
      end

      def parse(hash)
        hash ||= {}
        parsed_hash = schema.map do |key, type|
          value = hash[key]
          value ||= type.default if type.is_a?(Optional)
          [key, type.parse(value)]
        end.to_h
        OpenStruct.new(parsed_hash)
      end

      def type_check!(value, opt_hash = false)
        raise TypeError, "Expected Hash but found #{value.class}" unless value.is_a?(::Hash)
        check_schema!(value) unless opt_hash && is_like_nil?(value)
        check_unexpected_keys!(value)
      end

      def is_like_nil?(value)
        value.nil? || schema.map { |key, type| type.is_like_nil?(value[key]) }.all?
      end

    private
      def check_schema!(value)
        schema.each do |key, type|
          begin
            type.type_check!(value[key])
          rescue TypeError
            raise TypeError, "Invalid type for field '#{key}': expected #{type.describe_type} but was #{value[key].class}"
          end
        end
      end

      def check_unexpected_keys!(value)
        value.keys.each do |key|
          raise TypeError, "Unexpected field '#{key}' found in hash" unless schema.keys.include?(key)
        end
      end
    end
  end
end