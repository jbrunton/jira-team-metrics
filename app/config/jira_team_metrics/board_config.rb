class JiraTeamMetrics::BoardConfig < JiraTeamMetrics::BaseConfig

  QueryFilter = Struct.new(:name, :query)
  ConfigFilter = Struct.new(:name, :issues)
  PredictiveScope = Struct.new(:board_id, :adjustments_field)
  SyncOptions = Struct.new(:since, :subquery)

  def initialize(config_hash)
    super(config_hash, 'board_config')
  end

  def default_query
    config_hash['default_query'] || ''
  end

  def cycle_times
    config_hash['cycle_times']
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

  def sync_options
    if config_hash['sync'].nil?
      SyncOptions.new(nil, nil)
    else
      SyncOptions.new(
        config_hash['sync']['since'],
        config_hash['sync']['subquery'])
    end
  end
end