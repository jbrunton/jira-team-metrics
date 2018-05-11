class JiraTeamMetrics::Issue < ApplicationRecord
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
    board.domain.status_category_for(status)
  end

  def issues(opts)
    if is_epic?
      board.issues_in_epic(self)
    elsif is_increment?
      board.issues_in_increment(self, opts)
    else
      []
    end
  end

  def target_date
    if is_increment?
      # TODO: get this field name from config
      fields['Target Date'] ? Time.parse(fields['Target Date']) : nil
    end
  end

  def is_scope?
    !is_epic? && !is_increment?
  end

  def is_epic?
    issue_type == 'Epic'
  end

  def is_increment?
    board.domain.config.increment_types.any?{ |increment| issue_type == increment.issue_type }
  end

  def increment
    incr = links.find do |link|
      board.domain.config.increment_types.any? do |increment|
        link['inward_link_type'] == increment.inward_link_type &&
          link['issue']['issue_type'] == increment.issue_type
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

  def cycle_time
    cycle_time_between(nil, nil)
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
    if date < issue_created
      nil
    elsif status == 'Predicted'
      'Predicted'
    elsif completed_by?(date)
      'Done'
    elsif started_by?(date)
      'In Progress'
    else
      'To Do'
    end
  end

  def duration_in_range(date_range)
    if issue_type == 'Epic'
      0
    else
      if date_range.nil?
        0
      else
        overlap = date_range.overlap_with(JiraTeamMetrics::DateRange.new(started_time, completed_time))
        overlap.nil? ? 0 : overlap.duration
      end
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

  def completed_by?(date)
    completed_time && completed_time < date
  end

  def started_by?(date)
    started_time && started_time < date
  end
end
