class JiraTeamMetrics::BaseConfig
  attr_reader :config_hash

  def initialize(config_hash, schema_name)
    @config_hash = config_hash
    @schema_name = schema_name
  end

  def validate
    rx = Rx.new({ :load_core => true })
    schema_path = File.join(__dir__, 'schemas', "#{@schema_name}.yml")
    schema = rx.make_schema(YAML.load_file(schema_path))
    schema.check!(config_hash)
  end
end