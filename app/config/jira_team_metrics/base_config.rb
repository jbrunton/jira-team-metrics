class JiraTeamMetrics::BaseConfig
  attr_reader :config_hash

  def initialize(config_hash, schema_name)
    @config_hash = config_hash
    @schema_name = schema_name
  end

  def validate
    rx = Rx.new({ :load_core => true })
    rx.add_prefix('metrics', 'jira-team-metrics/')
    reports_schema_path = File.join(__dir__, 'schemas/types', 'reports_config.yml')
    rx.learn_type('jira-team-metrics/reports-config', YAML.load_file(reports_schema_path))
    schema_path = File.join(__dir__, 'schemas', "#{@schema_name}.yml")
    schema = rx.make_schema(YAML.load_file(schema_path))
    schema.check!(config_hash)
  end

  def report_options_for(report_name)
    if config_hash['reports'] && config_hash['reports'][report_name]
      sections = config_hash['reports'][report_name]['sections'].map do |section_hash|
        ReportSection.new(section_hash['title'], section_hash['mql'], section_hash['collapsed'])
      end
      ReportOptions.new(sections, config_hash['reports'][report_name]['backing_query'])
    end
  end

  def report_property_for(report_name, property_name)
    if config_hash['reports'] && config_hash['reports'][report_name]
      config_hash['reports'][report_name][property_name]
    end
  end

  ReportSection = Struct.new(:title, :mql, :collapsed)
  ReportOptions = Struct.new(:sections, :backing_query)
end
