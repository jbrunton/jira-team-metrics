class Board < ApplicationRecord
  belongs_to :domain
  has_many :issues, :dependent => :delete_all
  has_many :filters, :dependent => :delete_all

  validate :validate_config

  def exclusions
    exclusions_string = config_hash['exclude']
    exclusions_string ||= ''
    exclusions_string.split
  end

  def config_filters
    (config_hash['filters'] || []).map{ |h| h.deep_symbolize_keys }
  end

  def config
    DomainConfig.new(config_hash)
  end

  def config_hash
    YAML.load(config_string || '') || {}
  end

  def config_property(property)
    *scopes, property_name = property.split('.')
    config = config_hash
    while !scopes.empty?
      config = config[scopes.shift] || {}
    end
    value = config[property_name]
    value.deep_symbolize_keys! if value.is_a?(Hash)
    value
  end

  def validate_config
    config = BoardConfig.new(config_hash)
    begin
      config.validate
    rescue Exception => e
      errors.add(:config, e.message)
    end
  end

  DEFAULT_CONFIG = <<~CONFIG
    ---
    cycle_times:
      in_test:
        from: In Test
        to: Done
      in_review:
        from: In Review
        to: In Test
      in_progress:
        from: In Progress
        to: Done
    default_query: not filter = 'Outliers'
    filters:
      - name: Outliers
        issues:
          - key: ENG-101
            reason: blocked in test
    CONFIG
end
