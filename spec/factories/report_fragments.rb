FactoryBot.define do
  factory :report_fragment, class: JiraTeamMetrics::ReportFragment do
    board nil
report_key "MyString"
fragment_key "MyString"
contents "MyText"
  end

end
