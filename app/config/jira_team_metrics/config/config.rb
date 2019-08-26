class JiraTeamMetrics::Config::Config
  attr_reader :config_hash

  def initialize(config_hash, schema = nil, parent = nil)
    @config_hash = config_hash
    @schema = schema
    @parent = parent
    @config_values = JiraTeamMetrics::ConfigValues.new(config_hash, schema, @parent)
  end

  def validate
    rx = Rx.new({ :load_core => true })
    rx.add_prefix('metrics', 'jira-team-metrics/')
    reports_schema_path = File.join(__dir__, 'schemas/types', 'reports_config.yml')
    rx.learn_type('jira-team-metrics/reports-config', YAML.load_file(reports_schema_path))
    schema = rx.make_schema(@schema)
    schema.check!(config_hash)
  end

  def self.for(object)
    if object.class == JiraTeamMetrics::Domain
      JiraTeamMetrics::Config::ConfigParser.parse_domain(object.config_hash)
    elsif object.class == JiraTeamMetrics::Board
      JiraTeamMetrics::Config::ConfigParser.parse_board(object.config_hash, object.domain.config_hash)
    else
      raise "Unexpected class: #{object.class}"
    end
  end

  def self.domain_config(config_hash)
    JiraTeamMetrics::Config.new(config_hash, 'board_config')
  end

  def method_missing(method, *args)
    @config_values.method_missing(method, *args)
  end

  def has_key?(key)
    @config_values.has_key?(key)
  end
end
