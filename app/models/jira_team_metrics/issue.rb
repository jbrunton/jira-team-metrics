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

  def started_time
    first_transition = transitions.find do |t|
      t['toStatusCategory'] == 'In Progress'
    end

    first_transition ? Time.parse(first_transition['date']) : nil
  end

  def completed_time
    last_transition = transitions.reverse.find do |t|
      t['toStatusCategory'] == 'Done'
    end

    last_transition ? Time.parse(last_transition['date']) : nil
  end

  def cycle_time
    started = started_time
    completed = completed_time
    completed && started ? (completed - started) / (60 * 60 * 24) : nil
  end

  def domain_url
    "#{board.domain.config.url}/browse/#{key}"
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
    return 0 if issue_type == 'Epic' || date_range.nil?
    overlap = date_range.overlap_with(JiraTeamMetrics::DateRange.new(started_time, completed_time || Time.now))
    overlap.nil? ? 0 : overlap.duration
  end

private
  def completed_by?(date)
    completed_time && completed_time < date
  end

  def started_by?(date)
    started_time && started_time < date
  end
end
