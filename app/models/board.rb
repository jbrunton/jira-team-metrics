class Board < ApplicationRecord
  belongs_to :domain
  has_many :issues, :dependent => :delete_all
  has_many :filters, :dependent => :delete_all

  def exclusions
    config_hash = YAML.load(config || '')
    config_hash ||= {}
    exclusions_string = config_hash['exclude']
    exclusions_string ||= ''
    exclusions_string.split
  end

  DEFAULT_CONFIG = <<~CONFIG
    ---
    exclude:
  CONFIG
end
