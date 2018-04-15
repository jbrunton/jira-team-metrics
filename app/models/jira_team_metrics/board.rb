class JiraTeamMetrics::Board < JiraTeamMetrics::ApplicationRecord
  include JiraTeamMetrics::Configurable

  belongs_to :domain
  has_many :issues, :dependent => :delete_all
  has_many :filters, :dependent => :delete_all
  has_many :report_fragments, :dependent => :delete_all

  def exclusions
    exclusions_string = config_hash['exclude']
    exclusions_string ||= ''
    exclusions_string.split
  end

  def config_filters
    (config_hash['filters'] || []).map{ |h| h.deep_symbolize_keys }
  end

  def increments
    @increments ||= issues.select do |issue|
      domain.config.increment_types.any?{ |increment| issue.issue_type == increment.issue_type }
    end
  end

  def issues_in_epic(epic)
    issues.select{ |issue| issue.fields['Epic Link'] == epic.key }
  end

  def issues_in_increment(increment, opts)
    included_issues = increment.links.map do |link|
      if domain.config.increment_types.any? { |increment_type| increment_type.outward_link_type == link['outward_link_type'] }
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

  def training_increments
    if config.predictive_scope
      training_board = JiraTeamMetrics::Board.find_by(jira_id: config.predictive_scope.board_id)
      training_board.increments
    else
      []
    end
  end

  DEFAULT_CONFIG = <<~CONFIG
    ---
    cycle_times:
      in_test:
        from: In Test
        to: Done
      in_review:
        from: In Review
        to: In Test
      in_progress:
        from: In Progress
        to: Done
    default_query: not filter = 'Outliers'
    filters:
      - name: Outliers
        issues:
          - key: ENG-101
            reason: blocked in test
    CONFIG
end
