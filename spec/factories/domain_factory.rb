FactoryBot.define do
  factory :domain, class: JiraTeamMetrics::Domain do
    config_string "url: https://jira.example.com\nprojects:\n  issue_type: Project\n  inward_link_type: is included in\n  outward_link_type: includes"
    statuses "Backlog: To Do\nIn Progress: In Progress\nDone: Done"
  end
end