module JiraTeamMetrics::Types
  include Dry.Types

  module ClassMethods
    def string
      JiraTeamMetrics::Types::Strict::String
    end

    def bool
      JiraTeamMetrics::Types::Strict::Bool
    end

    def int
      JiraTeamMetrics::Types::Strict::Integer
    end

    def opt(type, default = nil)
      type.optional.meta(omittable: true).default(default)
    end

    def array_of(type)
      type = hash(type) if type.is_a?(::Hash)
      JiraTeamMetrics::Types::Strict::Array.of(type)
    end

    def opt_array_of(type)
      opt(array_of(type), [])
    end

    def hash(config_hash, schema)
      config_hash ||= {}
      config_hash = schema.map do |key, type|
        value = type[config_hash[key]]
        [key, value]
      end.to_h
      OpenStruct.new(config_hash)
    end
  end
end

class JiraTeamMetrics::ConfigParser
  extend JiraTeamMetrics::Types::ClassMethods

  def self.parse_domain(config_hash)
    OpenStruct.new(
      url: string[config_hash[:url]],
      name: opt(string)[config_hash[:name]],
      epics: hash(config_hash[:epics], {
        counting_strategy: opt(string),
        link_missing: opt(bool)
      })
    )
  end
end
