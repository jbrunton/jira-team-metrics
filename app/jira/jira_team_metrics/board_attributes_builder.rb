module JiraTeamMetrics
  class BoardAttributesBuilder
    def initialize(json)
      @json = json
    end

    def build
      {
        'jira_id' => jira_id,
        'query' => query,
        'name' => name
      }
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
end
