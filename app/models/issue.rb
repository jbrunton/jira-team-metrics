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
      progress_cycle_time = cycle_time_between(
        board.config_property('cycle_times.in_progress.from'),
        board.config_property('cycle_times.in_progress.to'))

      return {
        review_time: 0,
        test_time: 0,
        score: 0
      } if progress_cycle_time.nil?

      review_cycle_time = cycle_time_between(
        board.config_property('cycle_times.in_review.from'),
        board.config_property('cycle_times.in_review.to')) || 0

      test_cycle_time = cycle_time_between(
        board.config_property('cycle_times.in_test.from'),
        board.config_property('cycle_times.in_test.to')) || 0

      # i.e. downstream processes from development
      downstream_cycle_time = cycle_time_between(
        board.config_property('cycle_times.in_review.from'),
        board.config_property('cycle_times.in_test.to')) || 0

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
end
