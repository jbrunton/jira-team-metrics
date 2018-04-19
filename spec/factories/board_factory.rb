FactoryBot.define do
  factory :board, class: JiraTeamMetrics::Board do
    sequence(:jira_id) { |k| k }
    sequence(:name) { |k| "Board #{k}" }
    domain
    config_string JiraTeamMetrics::Board::DEFAULT_CONFIG
    query 'Project = MyProject'
  end
end
