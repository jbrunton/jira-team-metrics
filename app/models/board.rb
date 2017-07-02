class Board < ApplicationRecord
  belongs_to :domain
  has_many :issues, :dependent => :delete_all
  has_many :filters, :dependent => :delete_all

  def exclusions
    exclusions_string = config_hash['exclude']
    exclusions_string ||= ''
    exclusions_string.split
  end

  def config_filters
    config_hash['filters'] || []
  end

  def config_hash
    YAML.load(config || '') || {}
  end

  DEFAULT_CONFIG = <<~CONFIG
    ---
    exclude:
    filters:
  CONFIG
end
