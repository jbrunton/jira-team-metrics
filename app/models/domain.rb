class Domain < ApplicationRecord
  serialize :statuses
  has_many :boards, :dependent => :delete_all

  validates :name, presence: true
  validates :url, presence: true

  def config_hash
    YAML.load(config || '') || {}
  end
end
