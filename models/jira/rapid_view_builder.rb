class RapidBoardBuilder
  def initialize(json)
    @json = json
  end

  def build
    attrs = {
      'jira_id' => jira_id,
      'query' => query,
      'name' => name
    }

    RapidBoard.new(attrs)
  end

  private
  def jira_id
    @json['id']
  end

  def query
    @json['filter']['query']
  end

  def name
      @json['name']
  end
end
