module Jira
  class Issue
    attr_reader :key
    attr_reader :summary
    attr_reader :issue_type
    attr_reader :transitions

    def initialize(attrs)
      @key = attrs['key']
      @summary = attrs['summary']
      @issue_type = attrs['issue_type']
      @transitions = attrs['transitions']
    end

    def to_h
      {
        'key' => key,
        'summary' => summary,
        'issue_type' => issue_type,
        'transitions' => transitions
      }
    end
  end
end
