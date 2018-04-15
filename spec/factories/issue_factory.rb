FactoryBot.define do
  factory :issue, class: JiraTeamMetrics::Issue do
    sequence(:key) { |k| "ISSUE-#{k + 100}" }
    summary { "Some Issue" }
    board
  end
end