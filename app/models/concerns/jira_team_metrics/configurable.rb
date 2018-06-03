module JiraTeamMetrics::Configurable
  extend ActiveSupport::Concern
  include JiraTeamMetrics::EnvironmentHelper

  included do
    validate :validate_config
  end

  def config
    config_class = "#{self.class.name}Config".constantize
    config_class.new(config_hash)
  end

  private
  def config_hash
    YAML.load(config_string || '') || {}
  end

  def validate_config
    begin
      if readonly?
        errors.add(:config, 'Server started in readonly mode. Config is readonly.')
      else
        config.validate
      end
    rescue Rx::ValidationError => e
      errors.add(:config, e.message)
    end
  end
end
