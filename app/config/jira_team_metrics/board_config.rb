class JiraTeamMetrics::BoardConfig < JiraTeamMetrics::BaseConfig

  JqlFilter = Struct.new(:name, :query)
  MqlFilter = Struct.new(:name, :query)
  ConfigFilter = Struct.new(:name, :issues)
  PredictiveScope = Struct.new(:board_id, :adjustments_field)
  TimesheetsConfig = Struct.new(:day_of_week, :duration, :additional_columns)

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

  def timesheets_config
    return nil if config_hash['timesheets'].nil?

    TimesheetsConfig.new(
      config_hash['timesheets']['reporting_period']['day_of_week'].to_i,
      config_hash['timesheets']['reporting_period']['duration']['days'],
      config_hash['timesheets']['additional_columns'] || []
    )
  end

  def filters
    (config_hash['filters'] || []).map do |filter_hash|
      if filter_hash.key?('jql')
        JqlFilter.new(filter_hash['name'], filter_hash['jql'])
      elsif filter_hash.key?('mql')
        MqlFilter.new(filter_hash['name'], filter_hash['mql'])
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

  def epics_report_options(domain)
    report_options_for('epics') || domain.config.report_options_for('epics')
  end

  def projects_report_options(domain)
    report_options_for('projects') || domain.config.report_options_for('projects')
  end

  def scatterplot_default_query(domain)
    report_property_for('scatterplot', 'default_query') || domain.config.scatterplot_default_query
  end

  def aging_wip_completed_query(domain)
    report_property_for('aging_wip', 'completed_query') || domain.config.aging_wip_completed_query
  end
end