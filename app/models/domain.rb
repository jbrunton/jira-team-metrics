class Domain < ApplicationRecord
  include Configurable

  serialize :statuses
  serialize :fields
  has_many :boards, :dependent => :delete_all

  def increments
    config_hash['increments']
  end

  def synced_boards
    boards.where.not(boards: {last_synced: nil})
  end

  def self.get_instance
    Domain.first_or_create
  end
end