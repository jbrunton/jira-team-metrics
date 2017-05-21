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
    @started_cache = {}
    @completed_cache = {}
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
    @started_cache[status] ||= begin
      first_transition = transitions.find do |t|
        if status
          t['toStatus'] == status
        else
          t['toStatusCategory'] == 'In Progress'
        end
      end

      first_transition ? Time.parse(first_transition['date']) : nil
    end
  end

  def completed(status = nil)
    @completed_cache[status] ||= begin
      last_transition = transitions.reverse.find do |t|
        if status
          t['toStatus'] == status
        else
          t['toStatusCategory'] == 'Done'
        end
      end

      last_transition ? Time.parse(last_transition['date']) : nil
    end
  end

  def cycle_time
    completed && started ? (completed - started) / (60 * 60 * 24) : nil
  end

  def cycle_time_between(start_state, end_state)
    completed(start_state) && started(start_state) ? (completed(end_state) - started(start_state)) / (60 * 60 * 24) : nil
  end
end
