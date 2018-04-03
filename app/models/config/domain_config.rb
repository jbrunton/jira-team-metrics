class DomainConfig < BaseConfig
  RemoteBoardConfig = Struct.new(:jira_id, :config_url) do
    def fetch_config_string
      open(config_url).read
    end
  end

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

  def boards
    (config_hash['boards'] || []).map do |config_hash|
      RemoteBoardConfig.new(config_hash['jira_id'], config_hash['config_url'])
    end
  end
end