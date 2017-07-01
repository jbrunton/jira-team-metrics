class Domain < ApplicationRecord
  serialize :statuses
  has_many :boards, :dependent => :delete_all

  validates :name, presence: true
  validates :url, presence: true
end
