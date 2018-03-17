FactoryGirl.define do
  factory :issue do
    sequence(:key) { |k| "ISSUE-#{k + 100}" }
    summary { "Some Issue" }
    board
  end
end