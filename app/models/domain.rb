class Domain < ApplicationRecord
  include Configurable

  serialize :statuses
  serialize :fields
  has_many :boards, :dependent => :delete_all

  def synced_boards
    boards.where.not(boards: {last_synced: nil})
  end

  def status_category_for(status)
    config.status_category_overrides[status] || statuses[status]
  end

  def status_color_for(status)
    case status_category_for(status)
      when 'To Do'
        'blue'
      when 'In Progress'
        'yellow'
      when 'Done'
        'green'
      else
        nil
    end
  end

  def self.get_instance
    Domain.first_or_create
  end
end
