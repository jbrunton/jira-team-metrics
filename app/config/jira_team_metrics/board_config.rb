class JiraTeamMetrics::BoardConfig < JiraTeamMetrics::BaseConfig

  QueryFilter = Struct.new(:name, :query)
  ConfigFilter = Struct.new(:name, :issues)
  PredictiveScope = Struct.new(:board_id, :adjustments_field)

  def initialize(config_hash)
    super(config_hash, 'board_config')
  end

  def default_query
    config_hash['default_query'] || ''
  end

  def predictive_scope
    if config_hash['predictive_scope'].nil?
      nil
    else
      PredictiveScope.new(
        config_hash['predictive_scope']['board_id'],
        config_hash['predictive_scope']['adjustments_field']
      )
    end
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

  def sync_months
    if config_hash['sync'].nil?
      nil
    else
      config_hash['sync']['months'].to_i
    end
  end

  def rolling_window_days
    if config_hash['rolling_window'].nil?
      7
    else
      config_hash['rolling_window']['days'].to_i
    end
  end
end