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
    @instance ||= begin
      domain = Domain.first_or_create
      unless ENV['CONFIG_URL'].nil?
        domain.config_string = open(ENV['CONFIG_URL']).read
        domain.save
      end
      domain
    end
  end
end
