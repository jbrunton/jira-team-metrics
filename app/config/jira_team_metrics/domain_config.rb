class JiraTeamMetrics::DomainConfig < JiraTeamMetrics::BaseConfig
  BoardDetails = Struct.new(:board_id, :config_file) do
    def fetch_config_string(config_dir)
      unless config_file.nil?
        config_service = JiraTeamMetrics::ConfigFileService.new(config_file, config_dir)
        log_message = "CONFIG_FILE defined. Fetching config for board #{board_id} from #{config_service.config_file}"
        Rails.logger.info log_message
        open(config_service.config_file).read
      end
    end
  end

  TeamDetails = Struct.new(:name, :short_name)

  ProjectType = Struct.new(:issue_type, :outward_link_type, :inward_link_type)

  ProgressReportSection = Struct.new(:title, :mql)
  ProgressReportOptions = Struct.new(:sections)

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

  def project_type
    project_hash = config_hash['projects']
    return nil if project_hash.nil?
    ProjectType.new(project_hash['issue_type'], project_hash['outward_link_type'], project_hash['inward_link_type'])
  end

  def boards
    (config_hash['boards'] || []).map do |config_hash|
      BoardDetails.new(config_hash['board_id'], config_hash['config_file'])
    end
  end

  def teams
    (config_hash['teams'] || []).map do |team_hash|
      TeamDetails.new(team_hash['name'], team_hash['short_name'])
    end
  end

  def epics_report_options
    report_options_for('epics')
  end

  def projects_report_options
    report_options_for('projects')
  end

  def status_category_overrides
    @status_category_overrides ||= begin
      (config_hash['status_category_overrides'] || []).map do |override_hash|
        [override_hash['map'], override_hash['to_category']]
      end.to_h
    end
  end

private
  def report_options_for(report_name)
    if config_hash['reports'] && config_hash['reports'][report_name]
      sections = config_hash['reports'][report_name]['sections'].map do |section_hash|
        ProgressReportSection.new(section_hash['title'], section_hash['mql'])
      end
      ProgressReportOptions.new(sections)
    else
      ProgressReportOptions.new([])
    end
  end
end

