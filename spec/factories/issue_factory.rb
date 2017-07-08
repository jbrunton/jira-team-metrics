FactoryGirl.define do
  factory :issue do
    sequence(:key) { |k| "ISSUE-#{k + 100}" }
    summary { "Some issue #{key}" }
    board
  end
end