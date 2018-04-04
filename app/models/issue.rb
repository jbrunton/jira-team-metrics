class Issue < ApplicationRecord
  serialize :labels
  serialize :transitions
  serialize :fields
  serialize :links
  belongs_to :board

  def filters
    board.filters
      .select{ |filter| filter.include?(self) }
  end

  def outlier?
    filters.any?{ |filter| filter.name == 'Outliers' && filter.config_filter? }
  end

  def epic
    board.issues.where(key: fields['Epic Link']).first
  end

  def status_category
    # TODO: can this be retrieved directly from Jira?
    last_transition = transitions.last
    if last_transition.nil?
      'To Do'
    else
      last_transition['toStatusCategory']
    end
  end

  def increment
    incr = links.find do |link|
      board.domain.increments.any? do |increment|
        link['inward_link_type'] == increment['inward_link_type'] &&
          link['issue']['issue_type'] == increment['issue_type']
      end
    end
    if incr.nil?
      incr = epic.try(:increment)
    end
    incr
  end

  def short_summary
    summary.truncate(50, separator: /\s/)
  end

  def display_name
    "#{key} - #{summary}"
  end

  def short_display_name
    display_name.truncate(50, separator: /\s/)
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
    "#{board.domain.config.url}/browse/#{key}"
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

  def status_category_on(date)
    if was_to_do_on?(date)
      'To Do'
    elsif was_in_progress_on(date)
      'In Progress'
    elsif was_done_on?(date)
      'Done'
    end
  end

private
  def was_to_do_on?(date)
    issue_created < date && (started_time.nil? || date < started_time)
  end

  def was_in_progress_on(date)
    started_time && started_time < date && (completed_time.nil? || date < completed_time)
  end

  def was_done_on?(date)
    !completed_time.nil? && completed_time < date
  end

  def cycle_time_between_properties(start_property_name, end_property_name = nil)
    end_property_name = start_property_name if end_property_name.nil?
    start_property_name = "cycle_times.#{start_property_name}.from"
    end_property_name = "cycle_times.#{end_property_name}.to"

    cycle_time_between(
      board.config_property(start_property_name),
      board.config_property(end_property_name))
  end
end
