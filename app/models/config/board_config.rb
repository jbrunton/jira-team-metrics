class BoardConfig

  QueryFilter = Struct.new(:name, :query)
  ConfigFilter = Struct.new(:name, :issues)

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

  def filters
    (config_hash['filters'] || []).map do |filter_hash|
      if filter_hash.key?('query')
        QueryFilter.new(filter_hash['name'], filter_hash['query'])
      else
        ConfigFilter.new(filter_hash['name'], filter_hash['issues'])
      end
    end
  end

  def validate
    rx = Rx.new({ :load_core => true })
    schema = rx.make_schema(YAML.load_file(File.join(__dir__, 'board_config_schema.yml')))
    schema.check!(config_hash)
  end
end