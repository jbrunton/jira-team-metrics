FactoryBot.define do
  factory :domain, class: JiraTeamMetrics::Domain do
    config_string "url: https://jira.example.com"
    statuses "Backlog: To Do\nIn Progress: In Progress\nDone: Done"
  end
end