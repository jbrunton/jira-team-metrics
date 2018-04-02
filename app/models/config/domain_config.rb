class DomainConfig < BaseConfig
  def initialize(config_hash)
    super(config_hash, 'domain_config')
  end

  def fields
    config_hash['fields'] || []
  end

  def link_types
    config_hash['link_types'] || []
  end
end