class DomainConfig < BaseConfig
  RemoteBoardConfig = Struct.new(:jira_id, :config_url) do
    def fetch_config_string
      open(config_url).read
    end
  end

  IncrementType = Struct.new(:issue_type, :outward_link_type, :inward_link_type)

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

  def increment_types
    (config_hash['increments'] || []).map do |increment_hash|
      IncrementType.new(increment_hash['issue_type'], increment_hash['outward_link_type'], increment_hash['inward_link_type'])
    end
  end

  def boards
    (config_hash['boards'] || []).map do |config_hash|
      RemoteBoardConfig.new(config_hash['jira_id'], config_hash['config_url'])
    end
  end

  def status_category_overrides
    @status_category_overrides ||= begin
      (config_hash['status_category_overrides'] || []).map do |override_hash|
        [override_hash['map'], override_hash['to_category']]
      end.to_h
    end
  end
end