FactoryBot.define do
  factory :issue, class: JiraTeamMetrics::Issue do
    sequence(:key) { |k| "ISSUE-#{k + 100}" }
    summary "Some Issue"
    board
    fields {}
    status 'Done'

    factory :epic do
      issue_type 'Epic'
    end
  end
end