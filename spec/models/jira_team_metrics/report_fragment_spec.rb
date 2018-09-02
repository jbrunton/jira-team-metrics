require 'rails_helper'

RSpec.describe JiraTeamMetrics::ReportFragment, type: :model do
  let!(:board) { create(:board) }
  let!(:my_fragment_contents) { 'Fragment Contents' }
  let!(:my_fragment) {
    board.report_fragments.create(
      report_key: 'my_report',
      fragment_key: 'my_fragment',
      contents: my_fragment_contents)
  }

  describe ".fetch" do
    it "returns the fragment for the given report_key and fragment_key" do
      fragment = JiraTeamMetrics::ReportFragment.fetch(board, 'my_report', 'my_fragment')
      expect(fragment).to eq(my_fragment)
    end
  end

  describe ".fetch_contents" do
    it "returns the contents for the given report_key and fragment_key, if the fragment exists" do
      contents = JiraTeamMetrics::ReportFragment.fetch_contents(board, 'my_report', 'my_fragment')
      expect(contents).to eq(my_fragment_contents)
    end

    it "returns nil otherwise" do
      contents = JiraTeamMetrics::ReportFragment.fetch_contents(board, 'my_report', 'not_a_fragment')
      expect(contents).to eq(nil)
    end
  end
end
