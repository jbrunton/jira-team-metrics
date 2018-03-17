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

  def churn_metrics
    @churn_metrics ||= begin
      progress_cycle_time = cycle_time_between_properties('in_progress')

      return {
        review_time: 0,
        test_time: 0,
        score: 0
      } if progress_cycle_time.nil?

      review_cycle_time = cycle_time_between_properties('in_review') || 0
      test_cycle_time = cycle_time_between_properties('in_test') || 0

      # i.e. downstream processes from development
      downstream_cycle_time = cycle_time_between_properties('in_review', 'in_test') || 0

      review_time = review_cycle_time / progress_cycle_time
      test_time = test_cycle_time / progress_cycle_time
      score = downstream_cycle_time / progress_cycle_time

      {
        review_time: review_time * 100,
        test_time: test_time  * 100,
        score: score * 100
      }
    end
  end

private
  def cycle_time_between_properties(start_property_name, end_property_name = nil)
    end_property_name = start_property_name if end_property_name.nil?
    start_property_name = "cycle_times.#{start_property_name}.from"
    end_property_name = "cycle_times.#{end_property_name}.to"

    cycle_time_between(
      board.config_property(start_property_name),
      board.config_property(end_property_name))
  end
end
