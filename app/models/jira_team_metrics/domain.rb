class JiraTeamMetrics::Domain < JiraTeamMetrics::ApplicationRecord
  include JiraTeamMetrics::Configurable
  include JiraTeamMetrics::Synchronizable

  serialize :statuses
  serialize :fields
  has_many :boards, :dependent => :delete_all

  def synced_boards
    boards.where.not(jira_team_metrics_boards: {last_synced: nil})
  end

  def sync_in_progress?
    syncing?
  end

  def status_category_for(status)
    if status == 'Predicted'
      'Predicted'
    else
      config.status_category_overrides[status] || statuses[status]
    end
  end

  SHORT_TEAM_NAMES = {
    'Android' => 'and',
    'iOS' => 'ios',
    'OpsTools' => 'ops',
    'Core' => 'cor',
    'Jarvis' => 'jar',
    'BridgeAPI' => 'bri',
    'Billing' => 'bil',
    'Data & Analytics' => 'dat',
    'Member Web' => 'mem',
    'None' => 'non'
  }

  def short_team_name(full_team_name)
    SHORT_TEAM_NAMES[full_team_name]
  end

  def status_color_for(status)
    case status_category_for(status)
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

  def self.get_instance
    JiraTeamMetrics::Domain.first_or_create
  end
end
