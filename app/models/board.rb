class Board < ApplicationRecord
  belongs_to :domain
  has_many :issues, :dependent => :delete_all

  def exclusions
    YAML.load(config)['exclude'].split
  end
end
