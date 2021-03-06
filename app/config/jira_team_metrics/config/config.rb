class JiraTeamMetrics::Config::Config
  attr_reader :config_object

  def initialize(config_object, schema)
    @config_object = config_object
    @schema = schema
  end

  def validate
    @schema = JiraTeamMetrics::Config::Types::Hash.new(@schema) if @schema.is_a?(::Hash)
    @schema.type_check!(config_object.deep_to_h)
  end

  def self.for(object)
    if object.class == JiraTeamMetrics::Domain
      config_object = JiraTeamMetrics::Config::ConfigParser.parse_domain(object.config_hash)
      schema = JiraTeamMetrics::Config::ConfigParser::DomainSchema
    elsif object.class == JiraTeamMetrics::Board
      config_object = JiraTeamMetrics::Config::ConfigParser.parse_board(object.config_hash, object.domain.config_hash)
      schema = JiraTeamMetrics::Config::ConfigParser::BoardSchema
    else
      raise "Unexpected class: #{object.class}"
    end
    JiraTeamMetrics::Config::Config.new(config_object, schema)
  end

  def method_missing(method, *args)
    @config_object.method_missing(method, *args)
  end
end
