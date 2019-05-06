require 'rails_helper'

RSpec.describe JiraTeamMetrics::ReportFragment, type: :model do
  let(:jira_id) { 123 }
  let(:created_time) { DateTime.now }

  let(:my_fragment_contents) { 'Fragment Contents' }
  let(:sync_history) { JiraTeamMetrics::SyncHistory.create(jira_board_id: jira_id) }
  let!(:my_fragment) {
    travel_to created_time do
      JiraTeamMetrics::ReportFragment.create(
        report_key: 'my_report',
        fragment_key: 'my_fragment',
        contents: my_fragment_contents,
        sync_history: sync_history)
    end
  }

  let(:my_old_fragment_contents) { 'Old Fragment Contents' }
  let(:old_sync_history) { JiraTeamMetrics::SyncHistory.create(jira_board_id: jira_id) }
  let!(:my_old_fragment) do
    travel_to created_time - 1 do
      JiraTeamMetrics::ReportFragment.create(
        report_key: 'my_report',
        fragment_key: 'my_fragment',
        contents: my_old_fragment_contents,
        sync_history: old_sync_history)
    end
  end

  describe ".fetch" do
    it "returns the latest fragment for the given keys" do
      fragment = JiraTeamMetrics::ReportFragment.fetch(jira_id, 'my_report', 'my_fragment')
      expect(fragment).to eq(my_fragment)
    end

    it "returns the latest fragment for the matching sync_history_id when given" do
      fragment = JiraTeamMetrics::ReportFragment.fetch(jira_id, 'my_report', 'my_fragment', old_sync_history.id)
      expect(fragment).to eq(my_old_fragment)
    end

    context "if there are matching reports for another board" do
      let(:other_jira_id) { jira_id + 1 }
      let(:other_sync_history) { JiraTeamMetrics::SyncHistory.create(jira_board_id: other_jira_id) }
      let!(:other_board_fragment) do
        travel_to created_time + 1 do
          JiraTeamMetrics::ReportFragment.create(
            report_key: 'my_report',
            fragment_key: 'my_fragment',
            contents: 'Other Contents',
            sync_history: other_sync_history)
        end
      end

      it "returns the fragment for the expect board" do
        fragment1 = JiraTeamMetrics::ReportFragment.fetch(jira_id, 'my_report', 'my_fragment')
        fragment2 = JiraTeamMetrics::ReportFragment.fetch(other_jira_id, 'my_report', 'my_fragment')

        expect(fragment1).to eq(my_fragment)
        expect(fragment2).to eq(other_board_fragment)
      end
    end
  end

  describe ".fetch_contents" do
    it "returns the contents for the given report_key and fragment_key, if the fragment exists" do
      contents = JiraTeamMetrics::ReportFragment.fetch_contents(jira_id, 'my_report', 'my_fragment')
      expect(contents).to eq(my_fragment_contents)
    end

    it "returns the contents matching the report_key, fragment_key and sync_history_id, if the fragment exists" do
      contents = JiraTeamMetrics::ReportFragment.fetch_contents(jira_id,'my_report', 'my_fragment', old_sync_history.id)
      expect(contents).to eq(my_old_fragment_contents)
    end

    it "returns nil otherwise" do
      contents = JiraTeamMetrics::ReportFragment.fetch_contents(jira_id,'my_report', 'not_a_fragment')
      expect(contents).to eq(nil)
    end
  end
end
