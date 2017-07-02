class Board < ApplicationRecord
  belongs_to :domain
  has_many :issues, :dependent => :delete_all

  def config
    {
      exclude: "MOB-1110 MOB-1584 MOB-78 MOB-2084 MOB-2164 MOB-2172 MOB-2088 MOB-2041 MOB-2061 MOB-2075 MOB-2269"
    }
  end
end
