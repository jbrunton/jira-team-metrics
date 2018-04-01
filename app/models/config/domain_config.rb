class DomainConfig
  attr_reader :config_hash

  def initialize(config_hash)
    @config_hash = config_hash
  end

  def fields
    config_hash['fields'] || []
  end

  def link_types
    config_hash['link_types'] || []
  end

  def validate
    rx = Rx.new({ :load_core => true })
    schema = rx.make_schema(YAML.load_file(File.join(__dir__, 'domain_config_schema.yml')))
    schema.check!(config_hash)
  end
end