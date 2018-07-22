class JiraTeamMetrics::ConfigFileService
  attr_reader :domain
  attr_reader :config_file

  def initialize(config_file, config_dir)
    unless config_file.blank?
      if config_dir.blank?
        @config_file = config_file
      else
        @config_file = File.join(config_dir || '', config_file)
      end
    end
    @domain = JiraTeamMetrics::Domain.get_instance
  end

  def load_config
    unless @config_file.blank?
      log_message = "CONFIG_FILE defined. Setting config from #{@config_file}"
      Rails.logger.info log_message
      puts log_message # Rails doesn't print to stdout during boot

      @domain.config_string = open(@config_file).read
      unless @domain.save
        raise 'Invalid config: ' + @domain.errors.full_messages.join(',')
      end
    end
  end
end
