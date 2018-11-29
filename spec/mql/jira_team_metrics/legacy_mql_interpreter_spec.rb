# require 'rails_helper'
#
# RSpec.describe JiraTeamMetrics::LegacyMqlInterpreter do
#   let(:board) { create(:board) }
#
#   describe "#eval" do
#     context "when given a blank query" do
#       let(:issue) { create(:issue, key: 'ISSUE-101', board: board) }
#
#       it "returns all issues" do
#         issues = JiraTeamMetrics::LegacyMqlInterpreter.new(board, [issue]).eval("")
#         expect(issues).to eq([issue])
#       end
#     end
#
#     context "when given an issue field comparison" do
#       let(:issue) { create(:issue, key: 'ISSUE-101', board: board) }
#
#       it "returns issues that match the given value" do
#         issues = JiraTeamMetrics::LegacyMqlInterpreter.new(board, [issue]).eval("key = 'ISSUE-101'")
#         expect(issues).to eq([issue])
#       end
#
#       it "filters out issues that do not match the given value" do
#         issues = JiraTeamMetrics::LegacyMqlInterpreter.new(board, [issue]).eval("key = 'ISSUE-102'")
#         expect(issues).to be_empty
#       end
#     end
#
#     context "when given a jira field comparison" do
#       let(:issue) { create(:issue, fields: {'MyField' => 'foo'}, board: board) }
#
#       it "returns issues that match the given value" do
#         issues = JiraTeamMetrics::LegacyMqlInterpreter.new(board, [issue]).eval("MyField = 'foo'")
#         expect(issues).to eq([issue])
#       end
#
#       it "filters out issues that do not match the given value" do
#         issues = JiraTeamMetrics::LegacyMqlInterpreter.new(board, [issue]).eval("MyField = 'bar'")
#         expect(issues).to be_empty
#       end
#
#       it "filters names with spaces" do
#         issue2 = create(:issue, fields: {'My Field' => 'foo'}, board: board)
#         issue3 = create(:issue, fields: {'My Field' => 'bar'}, board: board)
#         issues = JiraTeamMetrics::LegacyMqlInterpreter.new(board, [issue2, issue3]).eval("'My Field' = 'foo'")
#         expect(issues).to eq([issue2])
#       end
#     end
#
#     context "when given an object field comparison" do
#       let(:issue) { create(:issue, issue_type: 'Bug', board: board) }
#
#       it "returns issues that match the given value" do
#         issues = JiraTeamMetrics::LegacyMqlInterpreter.new(board, [issue]).eval("issuetype = 'Bug'")
#         expect(issues).to eq([issue])
#       end
#
#       it "filters out issues that do not match the given value" do
#         issues = JiraTeamMetrics::LegacyMqlInterpreter.new(board, [issue]).eval("issuetype = 'Story'")
#         expect(issues).to be_empty
#       end
#     end
#
#     context "when given a date comparison" do
#       let(:issue_a) { create(:issue, issue_type: 'Bug', board: board, started_time: DateTime.now - 10) }
#       let(:issue_b) { create(:issue, issue_type: 'Bug', board: board, started_time: DateTime.now - 8, completed_time: DateTime.now - 6) }
#       let(:issue_c) { create(:issue, issue_type: 'Bug', board: board, started_time: DateTime.now - 6, completed_time: DateTime.now - 2) }
#
#       it "filters issues by the date" do
#         {
#             'completedTime > -4 days' => [issue_c],
#             'completedTime > -8 days' => [issue_b, issue_c],
#             'startedTime < -7 days' => [issue_a, issue_b]
#         }.each do |expr, expected_issues|
#           issues = JiraTeamMetrics::LegacyMqlInterpreter.new(board, [issue_a, issue_b, issue_c]).eval(expr)
#           expect(issues).to eq(expected_issues)
#         end
#       end
#     end
#
#     context "when given a project comparison" do
#       xit "returns issues in the given project"
#       xit "filters out issues that aren't in the given project"
#     end
#
#     context "when given an epic comparison" do
#       xit "returns issues in the given epic"
#       xit "filters out issues that aren't in the given epic"
#     end
#
#     context "when given a disjunction" do
#       let(:issue_a) { create(:issue, fields: {'MyField' => 'A'}, board: board) }
#       let(:issue_b) { create(:issue, fields: {'MyField' => 'B'}, board: board) }
#       let(:issue_c) { create(:issue, fields: {'MyField' => 'C'}, board: board) }
#
#       it "returns issues that match the disjunction" do
#         issues = JiraTeamMetrics::LegacyMqlInterpreter.new(board, [issue_a, issue_b, issue_c]).eval("MyField = 'A' or MyField = 'B'")
#         expect(issues).to eq([issue_a, issue_b])
#       end
#     end
#
#     context "when given a conjunction" do
#       let(:issue_a) { create(:issue, fields: {'FieldA' => 'foo', 'FieldB' => 'baz'}, board: board) }
#       let(:issue_b) { create(:issue, fields: {'FieldA' => 'foo', 'FieldB' => 'bar'}, board: board) }
#       let(:issue_c) { create(:issue, fields: {'FieldA' => 'bar', 'FieldB' => 'baz'}, board: board) }
#
#       it "returns issues that match the conjunction" do
#         issues = JiraTeamMetrics::LegacyMqlInterpreter.new(board, [issue_a, issue_b, issue_c]).eval("FieldA = 'foo' and FieldB = 'bar'")
#         expect(issues).to eq([issue_b])
#       end
#     end
#
#     context "when given a nested expression" do
#       let(:issue_a) { create(:issue, fields: {'FieldA' => 'foo', 'FieldB' => 'baz'}, board: board) }
#       let(:issue_b) { create(:issue, fields: {'FieldA' => 'foo', 'FieldB' => 'bar'}, board: board) }
#       let(:issue_c) { create(:issue, fields: {'FieldA' => 'bar', 'FieldB' => 'baz'}, board: board) }
#
#       it "returns the issues that match the expression" do
#         issues = JiraTeamMetrics::LegacyMqlInterpreter.new(board, [issue_a, issue_b, issue_c]).eval("(FieldA = 'foo' and FieldB = 'bar') or (FieldB = 'baz' and FieldA = 'bar')")
#         expect(issues).to eq([issue_b, issue_c])
#       end
#     end
#
#     context "when given a negated expression" do
#       let(:issue_a) { create(:issue, fields: {'MyField' => 'A'}, board: board) }
#       let(:issue_b) { create(:issue, fields: {'MyField' => 'B'}, board: board) }
#       let(:issue_c) { create(:issue, fields: {'MyField' => 'C'}, board: board) }
#
#       it "negates the expression" do
#         issues = JiraTeamMetrics::LegacyMqlInterpreter.new(board, [issue_a, issue_b, issue_c]).eval("not MyField = 'A'")
#         expect(issues).to eq([issue_b, issue_c])
#       end
#
#       it "negates compound expressions" do
#         issues = JiraTeamMetrics::LegacyMqlInterpreter.new(board, [issue_a, issue_b, issue_c]).eval("not (MyField = 'A' or MyField = 'B')")
#         expect(issues).to eq([issue_c])
#       end
#     end
#
#     context "when given a boolean expression" do
#       let(:issue_a) { create(:issue, started_time: DateTime.now) }
#       let(:issue_b) { create(:issue) }
#
#       it "returns issues for which it holds true" do
#         issues = JiraTeamMetrics::LegacyMqlInterpreter.new(board, [issue_a, issue_b]).eval("startedTime")
#         expect(issues).to eq([issue_a])
#       end
#     end
#
#     context "when given an includes expression" do
#       let(:issue) { create(:issue, fields: {'Teams' => ['Android']}, board: board) }
#
#       it "returns issues that match the given value" do
#         issues = JiraTeamMetrics::LegacyMqlInterpreter.new(board, [issue]).eval("Teams includes 'Android'")
#         expect(issues).to eq([issue])
#       end
#
#       it "filters out issues that do not match the given value" do
#         issues = JiraTeamMetrics::LegacyMqlInterpreter.new(board, [issue]).eval("Teams includes 'iOS'")
#         expect(issues).to be_empty
#       end
#     end
#
#     context "when given a sort clause" do
#       let(:issue1) { create(:issue, fields: {'MyField' => 'A'}, key: 'ISSUE-101', board: board) }
#       let(:issue2) { create(:issue, fields: {'MyField' => 'A'}, key: 'ISSUE-102', board: board) }
#       let(:issue3) { create(:issue, fields: {'MyField' => 'B'}, board: board) }
#
#       it "sorts the return values by the sort clause, ascending" do
#         issues = JiraTeamMetrics::LegacyMqlInterpreter.new(board, [issue1, issue2, issue3]).eval("MyField = 'A' sort by key asc")
#         expect(issues).to eq([issue1, issue2])
#       end
#
#       it "sorts the return values by the sort clause, descending" do
#         issues = JiraTeamMetrics::LegacyMqlInterpreter.new(board, [issue1, issue2, issue3]).eval("MyField = 'A' sort by key desc")
#         expect(issues).to eq([issue2, issue1])
#       end
#     end
#   end
# end