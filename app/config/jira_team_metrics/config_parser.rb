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

    def hash(schema)
      JiraTeamMetrics::Types::Hash.schema(schema)
    end

    def opt(type, default = nil)
      type.optional.meta(omittable: true).default(default.freeze)
    end

    def array_of(type)
      type = hash(type) if type.is_a?(::Hash)
      JiraTeamMetrics::Types::Strict::Array.of(type)
    end

    def opt_array_of(type)
      opt(array_of(type), [])
    end

    def parse(config_hash, schema)
      config_hash ||= {}
      config_hash = schema.map do |key, type|
        value = if type.is_a?(::Hash)
          parse(config_hash[key], type)
        elsif type.is_a?(::Method)
          # TODO: deprecate this path (for method refs)
          type[config_hash[key]]
        else
          config_hash[key].nil? ? type[] : type[config_hash[key]]
        end
        [key, value]
      end.to_h
      OpenStruct.new(config_hash)
    end
  end
end

class JiraTeamMetrics::ConfigParser
  extend JiraTeamMetrics::Types::ClassMethods

  ReportsSchema = {
    scatterplot: {
      default_query: opt(string)
    }
  }

  DomainSchema = {
    url: string,
    name: opt(string),
    epics: {
      counting_strategy: opt(string),
      link_missing: opt(bool)
    },
    boards: opt_array_of({
      board_id: int,
      config_file: opt(string)
    }),
    teams: opt_array_of({
      name: string,
      short_name: string
    }),
    reports: ReportsSchema
  }

  BoardSchema = {
    default_query: opt(string),
    epics: {
      counting_strategy: opt(string),
      link_missing: opt(bool)
    },
    predictive_scope: {
      board_id: int,
      adjustments_field: string
    },
    reports: ReportsSchema
  }

  def self.parse_domain(config_hash)
    parse(config_hash, DomainSchema)
  end

  def self.parse_board(board_config, domain_config)
    config = Config::Options.new
    config.add_source!(domain_config)
    config.add_source!(board_config)
    config.reload!
    config_hash = config.deep_to_h
    parse(config_hash, BoardSchema)
  end

  private

  def self.parse_reports(config_hash)
    config_hash ||= {}
    OpenStruct.new(
      scatterplot: OpenStruct.new(
        default_query: opt(string)[config_hash.try(:[], :scatterplot).try(:[], :default_query)]
      )
    )
  end
end
