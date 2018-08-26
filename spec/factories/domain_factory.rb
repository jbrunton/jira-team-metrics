FactoryBot.define do
  factory :domain, class: JiraTeamMetrics::Domain do
    config_string "url: https://jira.example.com\nprojects:\n  issue_type: Project\n  inward_link_type: is included in\n  outward_link_type: includes"
    statuses({ 'Backlog' => 'To Do', 'In Progress' => 'In Progress', 'Done' => 'Done' })
  end
end