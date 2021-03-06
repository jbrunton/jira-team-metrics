FactoryBot.define do
  factory :domain, class: JiraTeamMetrics::Domain do
    statuses({ 'Backlog' => 'To Do', 'In Progress' => 'In Progress', 'Done' => 'Done' })
    fields([
      {'id' => 'customfield_123', 'name' => 'MyField', 'type' => 'string'},
      {'id' => 'customfield_456', 'name' => 'teams', 'type' => 'array'}
    ])
    active true
    transient do
      project_issue_type 'Project'
    end

    before(:create) do |domain, evaluator|
      if domain.config_string.nil?
        domain.config_string = <<~CONFIG
          url: https://jira.example.com
          name: Test Domain
          projects:
            issue_type: #{evaluator.project_issue_type}
            inward_link_type: is included in
            outward_link_type: includes
        CONFIG
      end
    end
  end
end