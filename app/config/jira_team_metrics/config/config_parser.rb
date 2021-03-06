class JiraTeamMetrics::Config::ConfigParser
  module ClassMethods
    def string
      JiraTeamMetrics::Config::Types::String.new
    end

    def bool
      JiraTeamMetrics::Config::Types::Boolean.new
    end

    def int
      JiraTeamMetrics::Config::Types::Integer.new
    end

    def hash(schema)
      JiraTeamMetrics::Config::Types::Hash.new(schema)
    end

    def opt(type, default = nil)
      JiraTeamMetrics::Config::Types::Optional.new(type, default)
    end

    def array_of(type)
      type = hash(type) if type.is_a?(::Hash)
      JiraTeamMetrics::Config::Types::Array.new(type)
    end

    def opt_array_of(type)
      opt(array_of(type), [])
    end
  end

  extend ClassMethods

  def self.parse(config_hash, schema)
    schema = JiraTeamMetrics::Config::Types::Hash.new(schema) if schema.is_a?(::Hash)
    schema.parse(config_hash)
  end

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
    filters: opt_array_of({
      name: string,
      type: string,
      query: string
    }),
    predictive_scope: {
      board_id: int,
      adjustments_field: string
    },
    timesheets: {
      additional_columns: opt_array_of(string),
      reporting_period: {
        day_of_week: int,
        duration: {
          days: int
        }
      }
    },
    rolling_window: {
      days: int
    },
    sync: {
      months: int
    },
    reports: ReportsSchema
  }

  def self.parse_domain(config_hash)
    parse(config_hash, DomainSchema)
  end

  def self.parse_board(board_config, domain_config)
    config = Config::Options.new
    config.add_source!(domain_config) unless domain_config.nil?
    config.add_source!(board_config) unless board_config.nil?
    config.reload!
    config_hash = config.deep_to_h
    parse(config_hash, BoardSchema)
  end
end

class OpenStruct
  def deep_to_h
    to_h.transform_values do |value|
      case
        when value.is_a?(OpenStruct) then value.deep_to_h
        when value.is_a?(Array) then value.map{ |v| v.is_a?(OpenStruct) ? v.deep_to_h : v }
        else value
      end
    end
  end
end
