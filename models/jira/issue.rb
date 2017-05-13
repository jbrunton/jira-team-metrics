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

    def started(status = nil)
      first_transition = transitions.find do |t|
        if status
          t['status'] == status
        else
          t['statusCategory'] == 'In Progress'
        end
      end

      first_transition ? Time.parse(first_transition['date']) : nil
    end

    def completed(status = nil)
      last_transition = transitions.reverse.find do |t|
        if status
          t['status'] == status
        else
          t['statusCategory'] == 'Done'
        end
      end

      last_transition ? Time.parse(last_transition['date']) : nil
    end

    def cycle_time
      (completed_time - started_time) / (60 * 60 * 24)
    end

    def cycle_time_between(start_state, end_state)
      start_date = compute_started_date(start_state)
      end_date = compute_completed_date(end_state)
      if end_date && start_date
        (end_date - start_date) / (60 * 60 * 24)
      end
    end

  private

    def compute_started_date(start_state)
      started_transitions = transitions.select{ |t| t['stats'] == start_state }

      if started_transitions.any?
        Time.parse(started_transitions.first['date'])
      else
        nil
      end
    end

    def compute_completed_date(end_state)
      if !transitions.last.nil? && transitions.last['status'] == end_state
        Time.parse(transitions.last['date'])
      else
        nil
      end
    end
  end
end
