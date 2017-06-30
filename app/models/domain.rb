class Domain < ApplicationRecord
  serialize :statuses
  has_many :boards

  validates :name, presence: true
  validates :url, presence: true
end
