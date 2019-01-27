class JiraTeamMetrics::Config
  attr_reader :config_hash

  def initialize(config_hash, schema = nil, parent = nil)
    @config_hash = config_hash
    @schema = schema
    @parent = parent
  end

  def validate
    rx = Rx.new({ :load_core => true })
    rx.add_prefix('metrics', 'jira-team-metrics/')
    reports_schema_path = File.join(__dir__, 'schemas/types', 'reports_config.yml')
    rx.learn_type('jira-team-metrics/reports-config', YAML.load_file(reports_schema_path))
    schema = rx.make_schema(@schema)
    schema.check!(config_hash)
  end

  def get(key, default = nil)
    @config_hash.dig(*key.split('.')) || @parent.try(:get, key) || default
  end

  def project_type
    get('project_type')
  end

  def self.for(object)
    if object.class == JiraTeamMetrics::Domain
      schema_path = File.join(__dir__, 'schemas', 'domain_config.yml')
    elsif object.class == JiraTeamMetrics::Board
      schema_path = File.join(__dir__, 'schemas', 'board_config.yml')
    else
      raise "Unexpected class: #{object.class}"
    end
    schema = YAML.load_file(schema_path)
    JiraTeamMetrics::Config.new(object.config_hash, schema)
  end

  def self.domain_config(config_hash)
    JiraTeamMetrics::Config.new(config_hash, 'board_config')
  end
end
