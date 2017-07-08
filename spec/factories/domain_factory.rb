FactoryGirl.define do
  factory :domain do
    sequence(:name) { |k| "Domain #{k}" }
    url { "http://#{name}.example.com" }
  end
end