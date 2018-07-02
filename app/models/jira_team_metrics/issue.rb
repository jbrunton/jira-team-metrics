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
    elsif is_project?
      board.issues_in_project(self, opts)
    else
      []
    end
  end

  def teams
    if is_project?
      []
    elsif is_epic?
      fields['Teams'] || []
    else
      fields['Teams'] || epic.try(:teams) || []
    end
  end

  def target_date
    if is_project?
      # TODO: get this field name from config
      fields['Target Date'] ? DateTime.parse(fields['Target Date']) : nil
    end
  end

  def is_scope?
    !is_epic? && !is_project?
  end

  def is_epic?
    issue_type == 'Epic'
  end

  def is_project?
    board.domain.config.project_types.any?{ |project| issue_type == project.issue_type }
  end

  def project
    incr = links.find do |link|
      board.domain.config.project_types.any? do |project|
        link['inward_link_type'] == project.inward_link_type &&
          link['issue']['issue_type'] == project.issue_type
      end
    end
    if incr.nil?
      incr = epic.try(:project)
    end
    incr
  end

  def metric_adjustments
    @metric_adjustments ||= begin
      if is_project?
        yaml_string = fields[board.config.predictive_scope.adjustments_field]
        JiraTeamMetrics::MetricAdjustments.parse(yaml_string)
      end
    end
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

    first_transition ? DateTime.parse(first_transition['date']) : nil
  end

  def completed_time
    last_transition = transitions.reverse.find do |t|
      t['toStatusCategory'] == 'Done'
    end

    last_transition ? DateTime.parse(last_transition['date']) : nil
  end

  def cycle_time
    started = started_time
    completed = completed_time
    completed && started ? (completed - started).to_f : nil
  end

  def started?
    !started_time.nil?
  end

  def completed?
    started? && !completed_time.nil?
  end

  def in_progress?
    started? && !completed?
  end

  def completed_during?(date_range)
    completed? && date_range.contains?(completed_time)
  end

  def in_progress_during?(date_range)
    # issue is started before the range ends
    started? && started_time < date_range.end_date &&
        # and is either still in progress, or ends within the range
        (!completed? || completed_time >= date_range.start_date)
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
    JiraTeamMetrics::IssueHistoryAnalyzer.new(self).time_in_category('In Progress', date_range)
  end

  def transition_ranges

  end

  def time_in_category(status_category, date_range)

  end

private
  def completed_by?(date)
    completed_time && completed_time < date
  end

  def started_by?(date)
    started_time && started_time < date
  end
end
