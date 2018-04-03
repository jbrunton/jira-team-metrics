class DomainConfig < BaseConfig
  def initialize(config_hash)
    super(config_hash, 'domain_config')
  end

  def url
    config_hash['url'] || '<Unconfigured Domain>'
  end

  def name
    config_hash['name'] || url
  end

  # TODO: add Epic Link to this
  def fields
    config_hash['fields'] || []
  end

  def link_types
    config_hash['link_types'] || []
  end
end