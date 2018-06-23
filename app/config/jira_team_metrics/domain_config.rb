class JiraTeamMetrics::DomainConfig < JiraTeamMetrics::BaseConfig
  BoardDetails = Struct.new(:board_id, :config_url) do
    def fetch_config_string
      open(config_url).read unless config_url.nil?
    end
  end

  TeamDetails = Struct.new(:name, :short_name)

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
      BoardDetails.new(config_hash['board_id'], config_hash['config_url'])
    end
  end

  def teams
    (config_hash['teams'] || []).map do |team_hash|
      TeamDetails.new(team_hash['name'], team_hash['short_name'])
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

