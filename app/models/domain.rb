class Domain < ApplicationRecord
  serialize :statuses
  has_many :boards
end
