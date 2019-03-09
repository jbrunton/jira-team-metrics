class JiraTeamMetrics::ConfigFileService
  attr_reader :config_file

  def initialize(config_file, config_dir)
    @config_file = File.join(config_dir || 'config/', config_file) unless config_file.nil?
  end

  def load_config(target)
    unless @config_file.nil?
      if File.exist?(config_file)
        log_message = "Loading config from #{@config_file}"
        Rails.logger.info log_message
        puts log_message # Rails doesn't print to stdout during boot

        target.config_string = open(@config_file).read
        unless target.save
          raise 'Invalid config: ' + target.errors.full_messages.join(',')
        end
      else
        raise "Invalid config: #{@config_file} does not exist."
      end
    end
  end

  def self.load_domain_config
    unless ENV['CONFIG_DIR'].blank?
      JiraTeamMetrics::ConfigFileService.new('jira-team-metrics.yml', ENV['CONFIG_DIR'])
        .load_config(JiraTeamMetrics::Domain.get_active_instance)
    end
  end

  def self.load_board_config(board, config_file)
    JiraTeamMetrics::ConfigFileService.new(config_file, ENV['CONFIG_DIR']).load_config(board)
  end
end
