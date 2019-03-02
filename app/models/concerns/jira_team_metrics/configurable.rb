module JiraTeamMetrics::Configurable
  extend ActiveSupport::Concern
  include JiraTeamMetrics::EnvironmentHelper

  included do
    validate :validate_config
  end

  def config
    JiraTeamMetrics::Config.for(self)
  end

  def config_hash
    YAML.load(config_string || '') || {}
  end

  private
  def validate_config
    begin
      config.validate
    rescue Rx::ValidationError => e
      errors.add(:config, e.message)
    end
  end
end
