class JiraTeamMetrics::Board < JiraTeamMetrics::ApplicationRecord
  include JiraTeamMetrics::Configurable

  belongs_to :domain
  has_many :issues, :dependent => :delete_all
  has_many :filters, :dependent => :delete_all
  has_many :report_fragments, :dependent => :delete_all

  def sync_in_progress?
    domain.sync_in_progress?
  end

  def exclusions
    exclusions_string = config_hash['exclude']
    exclusions_string ||= ''
    exclusions_string.split
  end

  def config_filters
    (config_hash['filters'] || []).map{ |h| h.deep_symbolize_keys }
  end

  def projects
    @projects ||= issues.select do |issue|
      [domain.config.project_type].compact.any?{ |project| issue.issue_type == project.issue_type }
    end
  end

  def issues_in_epic(epic)
    issues.select{ |issue| issue.fields['Epic Link'] == epic.key }
  end

  def issues_in_project(project, opts)
    included_issues = project.links.map do |link|
      if [domain.config.project_type].compact.any? { |project_type| project_type.outward_link_type == link['outward_link_type'] }
        issues.find_by(key: link['issue']['key'])
      else
        nil
      end
    end.compact
    if opts[:recursive]
      included_issues.map{ |issue| [issue] + issue.issues(recursive: false) }.flatten.compact.uniq
    else
      included_issues
    end
  end

  def completed_issues(date_range)
    @completed_issues ||= begin
      self.issues
        .select do |issue|
          issue.completed_time && issue.started_time &&
              date_range.start_date <= issue.completed_time &&
              issue.completed_time < date_range.end_date
        end
        .sort_by{ |i| i.completed_time }
    end
  end

  def wip_issues
    @in_progress_issues ||= begin
      self.issues
        .select{ |i| i.started_time && !i.completed_time }
    end
  end

  def issue_types
    issues.map{ |issue| issue.issue_type }.uniq
  end

  def config_property(property)
    *scopes, property_name = property.split('.')
    config = config_hash
    while !scopes.empty?
      config = config[scopes.shift] || {}
    end
    value = config[property_name]
    value.deep_symbolize_keys! if value.is_a?(Hash)
    value
  end

  def training_board
    if config.predictive_scope
      JiraTeamMetrics::Board.find_by(jira_id: config.predictive_scope.board_id)
    else
      nil
    end
  end

  def training_projects
    if config.predictive_scope
      training_board.projects
    else
      []
    end
  end

  def sync_query(months)
    query_builder = JiraTeamMetrics::QueryBuilder.new(query)
    sync_subquery = build_sync_subquery(months)
    query_builder.and(sync_subquery) unless sync_subquery.blank?
    query_builder.query
  end

  def sync_from(months)
    if months.nil?
      nil
    else
      current_time = DateTime.now
      years_diff = months / 12
      months_diff = months - years_diff * 12
      new_year = current_time.year - years_diff
      new_month = current_time.month - months_diff
      if new_month <= 0
        new_year = new_year - 1
        new_month = new_month + 12
      end
      DateTime.new(new_year, new_month)
    end
  end

private
  def build_sync_subquery(months)
    if months.nil?
      nil
    else
      sync_from_fm = sync_from(months).strftime('%Y-%m-%d')
      "statusCategory = \"In Progress\" OR status CHANGED AFTER \"#{sync_from_fm}\""
    end
  end
end
