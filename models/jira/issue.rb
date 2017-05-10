module Jira
  class Issue
    attr_reader :key
    attr_reader :summary
    attr_reader :issue_type
    attr_reader :transitions
    attr_reader :started
    attr_reader :completed

    def initialize(attrs)
      @key = attrs['key']
      @summary = attrs['summary']
      @issue_type = attrs['issue_type']
      @transitions = attrs['transitions']
      @started = attrs['started']
      @completed = attrs['completed']
    end

    def to_h
      {
        'key' => key,
        'summary' => summary,
        'issue_type' => issue_type,
        'transitions' => transitions,
        'started' => started,
        'completed' => completed
      }
    end

    def started_time
      @started_time ||= Time.parse(started)
    end

    def completed_time
      @completed_time ||= Time.parse(completed)
    end

    def cycle_time
      (completed_time - started_time) / (60 * 60 * 24)
    end
  end
end
