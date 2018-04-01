class Domain < ApplicationRecord
  serialize :statuses
  serialize :fields
  has_many :boards, :dependent => :delete_all

  validates :name, presence: true
  validates :url, presence: true
  validate :validate_config

  def config_hash
    @config_hash ||= begin
      domain_config = DomainConfig.new(YAML.load(config_string || '') || {})
      domain_config.validate
      domain_config.config_hash
    end
  end

  def link_types
    config_hash['link_types']
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
