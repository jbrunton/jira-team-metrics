FactoryBot.define do
  factory :board, class: JiraTeamMetrics::Board do
    sequence(:jira_id) { |k| k }
    sequence(:name) { |k| "Board #{k}" }
    domain
    config_string { 'url: jira.example.com' }
    query 'Project = MyProject'
  end
end
