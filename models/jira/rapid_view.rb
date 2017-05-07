module Jira
  class RapidBoard
    attr_reader :id
    attr_reader :query
    attr_reader :name
    attr_reader :issues

    def initialize(attrs)
      @id = attrs[:id]
      @query = attrs[:query]
      @name = attrs[:name]
      @issues = attrs[:issues]
    end
  end
end
