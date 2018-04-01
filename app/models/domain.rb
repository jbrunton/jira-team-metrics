class Domain < ApplicationRecord
  serialize :statuses
  serialize :fields
  has_many :boards, :dependent => :delete_all

  validates :name, presence: true
  validates :url, presence: true
  validate :validate_config

  def config
    DomainConfig.new(config_hash)
  end

  def config_hash
    YAML.load(config_string || '') || {}
  end

  def increments
    config_hash['increments']
  end

  def synced_boards
    boards.where.not(boards: {last_synced: nil})
  end

  def validate_config
    domain_config = DomainConfig.new(YAML.load(config_string || '') || {})
    begin
      domain_config.validate
    rescue Exception => e
      errors.add(:config, e.message)
    end
  end
end
