class Board < ApplicationRecord
  include Configurable

  belongs_to :domain
  has_many :issues, :dependent => :delete_all
  has_many :filters, :dependent => :delete_all

  def exclusions
    exclusions_string = config_hash['exclude']
    exclusions_string ||= ''
    exclusions_string.split
  end

  def config_filters
    (config_hash['filters'] || []).map{ |h| h.deep_symbolize_keys }
  end

  def increments
    issues.select do |issue|
      domain.config.increments.any?{ |increment| issue.issue_type == increment.issue_type }
    end
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
