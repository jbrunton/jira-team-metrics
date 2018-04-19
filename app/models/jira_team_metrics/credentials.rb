class JiraTeamMetrics::Credentials
  include ActiveModel::Model

  attr_accessor :username, :password

  validates :username, presence: true
  validates :password, presence: true

  def to_serializable_hash
    {
      'username' => username,
      'password' => password
    }
  end
end
