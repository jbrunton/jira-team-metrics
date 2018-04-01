class BoardConfig
  attr_reader :config_hash

  def initialize(config_hash)
    @config_hash = config_hash
  end

  def default_query
    config_hash['default_query'] || ''
  end

  def cycle_times
    config_hash['cycle_times']
  end

  def validate
    rx = Rx.new({ :load_core => true })
    schema = rx.make_schema(YAML.load_file(File.join(__dir__, 'board_config_schema.yml')))
    schema.check!(config_hash)
  end
end