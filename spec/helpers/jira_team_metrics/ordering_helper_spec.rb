require 'rails_helper'

RSpec.describe JiraTeamMetrics::OrderingHelper do
  let(:today) { DateTime.new(2018, 1, 1) }

  let!(:epic) { create(:epic) }
  let!(:done1) { create(:issue, epic: epic, status: 'Done', started_time: today - 5, completed_time: today - 4) }
  let!(:progress1) { create(:issue, epic: epic, status: 'In Progress', started_time: today - 5) }
  let!(:backlog1) { create(:issue, epic: epic, status: 'Backlog') }

  it "orders issues in an epic by the status category" do
    expect(helper.issues_in_epic(epic)).to eq([progress1, backlog1, done1])
  end

  it "orders in progress issues by global rank" do
    progress2 = create(:issue, epic: epic, global_rank: '100', status: 'In Progress', started_time: today - 5)
    expect(helper.issues_in_epic(epic)).to eq([progress2, progress1, backlog1, done1])
  end

  it "orders backlog issues by global rank" do
    backlog2 = create(:issue, epic: epic, global_rank: '100', status: 'Backlog')
    expect(helper.issues_in_epic(epic)).to eq([progress1, backlog2, backlog1, done1])
  end

  it "orders done issues by started time" do
    done2 = create(:issue, epic: epic, started_time: done1.started_time - 1, completed_time: done1.completed_time, status: 'Backlog')
    expect(helper.issues_in_epic(epic)).to eq([progress1, backlog1, done2, done1])
  end
end