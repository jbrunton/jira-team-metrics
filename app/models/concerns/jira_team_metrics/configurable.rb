module JiraTeamMetrics::Configurable
  extend ActiveSupport::Concern
  include JiraTeamMetrics::EnvironmentHelper

  included do
    validate :validate_config
  end

  def reload(options = nil)
    super
    @config = nil
  end

  def config
    @config ||= JiraTeamMetrics::Config.for(self)
  end

  def config_hash
    YAML.load(config_string || '') || {}
  end

  private
  def validate_config
    begin
      @config = nil
      config.validate
    rescue Rx::ValidationError => e
      errors.add(:config, e.message)
    end
  end
end
