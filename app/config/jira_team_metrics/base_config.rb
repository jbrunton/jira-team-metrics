class JiraTeamMetrics::BaseConfig
  attr_reader :config_hash

  def initialize(config_hash, schema_name)
    @config_hash = config_hash
    @schema_name = schema_name
  end

  def validate
    rx = Rx.new({ :load_core => true })
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

  ReportSection = Struct.new(:title, :mql, :collapsed)
  ReportOptions = Struct.new(:sections, :backing_query)
end
