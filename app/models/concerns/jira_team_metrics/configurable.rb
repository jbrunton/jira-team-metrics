module JiraTeamMetrics::Configurable
  extend ActiveSupport::Concern
  include JiraTeamMetrics::EnvironmentHelper

  included do
    validate :validate_config
  end

  def reload(options = nil)
    clear_config
    super
  end

  def config_string=(value)
    clear_config
    super
  end

  def config
    @config ||= JiraTeamMetrics::Config::Config.for(self)
  end

  def config_hash
    config_string.blank? ? {} : YAML.load(config_string).deep_symbolize_keys
  end

  private
  def validate_config
    begin
      #config.validate
    rescue Rx::ValidationError => e
      #errors.add(:config, e.message)
    end
  end

  def clear_config
    @config = nil
  end
end
