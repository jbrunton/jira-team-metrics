class Domain < ApplicationRecord
  serialize :statuses
  serialize :fields
  has_many :boards, :dependent => :delete_all

  validates :name, presence: true
  validates :url, presence: true

  def config_hash
    YAML.load(config || '') || {}
  end

  def synced_boards
    boards.where.not(boards: {last_synced: nil})
  end
end
