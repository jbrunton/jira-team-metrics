class JiraTeamMetrics::Domain < JiraTeamMetrics::ApplicationRecord
  include JiraTeamMetrics::Configurable

  serialize :statuses
  serialize :fields
  has_many :boards, :dependent => :delete_all

  has_many :issues, :through => :boards

  after_save :clear_cache

  def domain
    self
  end

  def synced_boards
    boards.where.not(jira_team_metrics_boards: {last_synced: nil})
  end

  def status_category_for(status)
    if status == 'Predicted'
      'Predicted'
    else
      config.status_category_overrides[status] || statuses[status]
    end
  end

  def short_team_name(full_team_name)
    team = config.teams.find{ |t| t.name == full_team_name }
    team.nil? ? full_team_name.gsub(/\s+/, '')[0..2].downcase : team.short_name
  end

  def status_color_for(status_category)
    case status_category
      when 'To Do'
        'red'
      when 'Predicted'
        'orange'
      when 'In Progress'
        'green'
      when 'Done'
        'blue'
      else
        nil
    end
  end

  def is_project?(issue)
    @project_type ||= config.project_type.try(:issue_type)
    @project_type == issue.issue_type
  end

  def self.get_active_instance
    @active_domain ||= JiraTeamMetrics::Domain.first_or_create(active: true)
  end

  def self.clear_cache
    @active_domain = nil
  end

  def clear_cache
    JiraTeamMetrics::Domain.clear_cache
  end
end
