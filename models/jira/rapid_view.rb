class RapidBoard
  attr_reader :id
  attr_reader :query
  attr_reader :name
  attr_reader :issues
  attr_reader :last_updated
  attr_reader :changed_issues_since

  def initialize(attrs)
    @id = attrs['id']
    @query = attrs['query']
    @name = attrs['name']
    @issues = attrs['issues']
    @last_updated = attrs['last_updated']
    @changed_issues_since = attrs['changed_issues_since']
  end

  def to_h
    {
      'id' => id,
      'name' => name,
      'query' => query
    }
  end
end
