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

    # def hash(config_hash, schema)
    #   config_hash ||= {}
    #   config_hash = schema.map do |key, type|
    #     value = type[config_hash[key]]
    #     [key, value]
    #   end.to_h
    #   OpenStruct.new(config_hash)
    # end
  end
end

class JiraTeamMetrics::ConfigParser
  extend JiraTeamMetrics::Types::ClassMethods

  def self.parse_domain(config_hash)
    OpenStruct.new(
      url: string[config_hash[:url]],
      name: opt(string)[config_hash[:name]],
      epics: parse_epics(config_hash[:epics]),
      boards: parse_boards(config_hash[:boards]),
      teams: parse_teams(config_hash[:teams]),
      reports: parse_reports(config_hash[:reports])
    )
  end

  def self.parse_board(board_config, domain_config)
    config = Config::Options.new
    config.add_source!(domain_config)
    config.add_source!(board_config)
    config.reload!
    config_hash = config.deep_to_h
    OpenStruct.new(
      default_query: opt(string)[config_hash[:default_query]],
      epics: parse_epics(config_hash[:epics]),
      predictive_scope: parse_predictive_scope(config_hash[:predictive_scope]),
      reports: parse_reports(config_hash[:reports])
    )
  end

  private

  def self.parse_epics(config_hash)
    config_hash ||= {}
    OpenStruct.new(
      counting_strategy: opt(string)[config_hash[:counting_strategy]],
      link_missing: opt(bool)[config_hash[:link_missing]]
    )
  end

  def self.parse_boards(config_array)
    config_array ||= []
    config_array.map do |config_hash|
      OpenStruct.new(
        board_id: int[config_hash[:board_id]],
        config_file: opt(string)[config_hash[:config_file]]
      )
    end
  end

  def self.parse_teams(config_array)
    config_array ||= []
    config_array.map do |config_hash|
      OpenStruct.new(
        name: string[config_hash[:name]],
        short_name: string[config_hash[:short_name]]
      )
    end
  end

  def self.parse_predictive_scope(config_hash)
    config_hash ||= {}
    OpenStruct.new(
      board_id: int[config_hash[:board_id]],
      adjustments_field: string[config_hash[:adjustments_field]]
    )
  end

  def self.parse_reports(config_hash)
    config_hash ||= {}
    OpenStruct.new(
      scatterplot: OpenStruct.new(
        default_query: opt(string)[config_hash.try(:[], :scatterplot).try(:[], :default_query)]
      )
    )
  end
end
