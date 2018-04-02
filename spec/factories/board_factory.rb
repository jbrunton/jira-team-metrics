FactoryGirl.define do
  factory :board do
    sequence(:jira_id) { |k| k }
    sequence(:name) { |k| "Board #{k}" }
    domain
    config_string Board::DEFAULT_CONFIG
  end
end