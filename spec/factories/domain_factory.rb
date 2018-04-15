FactoryBot.define do
  factory :domain, class: JiraTeamMetrics::Domain do
    config_string "url: https://jira.example.com"
  end
end