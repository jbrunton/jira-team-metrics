class Issue < ApplicationRecord
  serialize :labels
  serialize :transitions
  serialize :fields
  belongs_to :board

  def short_summary
    summary.truncate(50, separator: /\s/)
  end

  def started_time(status = nil)
    first_transition = transitions.find do |t|
      if status
        t['toStatus'] == status
      else
        t['toStatusCategory'] == 'In Progress'
      end
    end

    first_transition ? Time.parse(first_transition['date']) : nil
  end

  def completed_time(status = nil)
    last_transition = transitions.reverse.find do |t|
      if status
        t['toStatus'] == status
      else
        t['toStatusCategory'] == 'Done'
      end
    end

    last_transition ? Time.parse(last_transition['date']) : nil
  end

  def cycle_time_between(start_state, end_state)
    started = started_time(start_state)
    completed = completed_time(end_state)
    completed && started ? (completed - started) / (60 * 60 * 24) : nil
  end

  def domain_url
    "#{board.domain.url}/browse/#{key}"
  end
end
