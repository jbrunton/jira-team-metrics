module Jira
  class RapidBoard
    attr_reader :id
    attr_reader :query
    attr_reader :name

    def initialize(attrs)
      @id = attrs[:id]
      @query = attrs[:query]
      @name = attrs[:name]
    end
  end
end
