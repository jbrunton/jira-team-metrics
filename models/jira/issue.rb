module Jira
  class Issue
    attr_reader :key
    attr_reader :summary
    attr_reader :issue_type

    def initialize(attrs)
      @key = attrs['key']
      @summary = attrs['summary']
      @issue_type = attrs['issue_type']
    end

    def to_h
      {
        'key' => key,
        'summary' => summary,
        'issue_type' => issue_type
      }
    end
  end
end
