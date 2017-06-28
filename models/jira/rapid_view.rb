class RapidBoard
  attr_reader :jira_id
  attr_reader :query
  attr_reader :name
  attr_reader :issues
  attr_reader :last_updated
  attr_reader :sync_from

  def initialize(attrs)
    @jira_id = attrs['jira_id']
    @query = attrs['query']
    @name = attrs['name']
    @issues = attrs['issues']
    @last_updated = attrs['last_updated']
    @sync_from = attrs['sync_from']
  end

  def to_h
    {
      'jira_id' => jira_id,
      'name' => name,
      'query' => query
    }
  end
end
