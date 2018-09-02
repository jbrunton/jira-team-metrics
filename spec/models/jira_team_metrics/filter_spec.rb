require 'rails_helper'

describe JiraTeamMetrics::Filter do
  let!(:board) { create(:board) }
  let!(:issue_one) { create(:issue) }
  let!(:issue_two) { create(:issue) }
  let!(:jql_filter) { board.filters.create(filter_type: :jql_filter, issue_keys: issue_one.key) }

  describe "#include?" do
    it "returns true if the issue is in the filter" do
      expect(jql_filter.include?(issue_one)).to eq(true)
      expect(jql_filter.include?(issue_two)).to eq(false)
    end
  end

  describe "#add_issue" do
    context "if the filter_type is :config_filter" do
      let(:config_filter) { board.filters.create(filter_type: :config_filter, issue_keys: '') }

      it "adds the issue key to the filter" do
        config_filter.add_issue(issue_one)
        expect(config_filter.issue_keys).to eq(" #{issue_one.key}")
      end
    end

    context "if the filter_type is not :config_filter" do
      it "raises an exception" do
        expect{ jql_filter.add_issue(issue_one) }.to raise_error(RuntimeError, /Cannot add issues to filters of type jql_filter/)
      end
    end
  end

  describe "#remove_issue" do
    context "if the filter_type is :config_filter" do
      let(:config_filter) { board.filters.create(filter_type: :config_filter, issue_keys: issue_one.key) }

      it "removes the issue key to the filter" do
        config_filter.remove_issue(issue_one)
        expect(config_filter.issue_keys).to eq('')
      end
    end

    context "if the filter_type is not :config_filter" do
      it "raises an exception" do
        expect{ jql_filter.remove_issue(issue_one) }.to raise_error(RuntimeError, /Cannot remove issues from filters of type jql_filter/)
      end
    end
  end
end