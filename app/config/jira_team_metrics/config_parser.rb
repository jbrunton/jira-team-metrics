module JiraTeamMetrics::Types
  #include Dry.Types
  #


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
        if type.is_a?(::Hash)
          value = parse(config_hash[key], type)
        else
          begin
            value = config_hash[key].nil? ? type[] : type[config_hash[key]]
            value.map { |x| parse(x, schema[key])} if value.is_a?(::Array)
          rescue Dry::Types::ConstraintError => e
            raise "Invalid type in config for field '#{key}': expected #{type.rule.to_s} but was #{config_hash[key].class}."
          end
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
    epics: {
      backing_query: opt(string),
      card_layout: {
        fields: opt_array_of(string)
      },
      sections: opt_array_of({
        title: string,
        mql: string,
        collapsed: opt(bool),
        min: opt(int),
        max: opt(int)
      })
    },
    projects: {
      backing_query: opt(string),
      card_layout: {
        fields: opt_array_of(string)
      },
      sections: opt_array_of({
        title: string,
        mql: string,
        collapsed: opt(bool)
      })
    },
    scatterplot: {
      default_query: opt(string)
    },
    throughput: {
      default_query: opt(string)
    },
    aging_wip: {
      default_query: opt(string),
      fields: opt_array_of(string)
    },
    custom_reports: opt_array_of({
      name: string,
      query: string,
      description: opt(string)
    })
  }

  DomainSchema = {
    url: string,
    name: opt(string),
    fields: opt_array_of(string),
    projects: {
      issue_type: string,
      inward_link_type: string,
      outward_link_type: string
    },
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
end
