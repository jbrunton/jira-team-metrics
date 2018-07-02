require 'rails_helper'

RSpec.describe JiraTeamMetrics::PathHelper do
  before(:each) { helper.define_singleton_method(:root_path) { '/metrics/' } }

  let(:board) { create(:board, jira_id: 101) }
  let(:project) { board.issues.create(attributes_for(:issue, key: 'DELIVERY-1')) }

  it "defines #domain path" do
    expect(helper.domain_path).to eq('/metrics/domain')
  end

  it "defines #domain_metadata path" do
    expect(helper.domain_metadata_path).to eq('/metrics/domain/metadata')
  end

  it "defines #board_path" do
    expect(helper.board_path(board)).to eq('/metrics/domain/boards/101')
  end

  it "defines #reports_path" do
    expect(helper.reports_path(board)).to eq('/metrics/reports/boards/101')
  end

  it "defines #projects_report_path" do
    expect(helper.projects_report_path(board)).to eq('/metrics/reports/boards/101/projects')
  end

  it "defines #project_report_path" do
    expect(helper.project_report_path(board, project)).to eq('/metrics/reports/boards/101/projects/DELIVERY-1')
  end

  it "defines #project_scope_report_path" do
    expect(helper.project_scope_report_path(board, project, 'MyTeam')).to eq('/metrics/reports/boards/101/projects/DELIVERY-1/scope/MyTeam')
  end

  it "defines #project_throughput_report_path" do
    expect(helper.project_throughput_report_path(board, project, 'MyTeam')).to eq('/metrics/reports/boards/101/projects/DELIVERY-1/throughput/MyTeam')
  end

  it "defines #timesheets_report_path" do
    expect(helper.timesheets_report_path(board)).to eq('/metrics/reports/boards/101/timesheets')
  end

  it "defines #timesheets_report_path for a given date range" do
    start_date = DateTime.new(2001, 1, 1)
    date_range = JiraTeamMetrics::DateRange.new(start_date, start_date + 1)
    expect(helper.timesheets_report_path(board, date_range)).to eq('/metrics/reports/boards/101/timesheets?from_date=2001-01-01&to_date=2001-01-02')
  end

  it "defines #board_components_path" do
    expect(helper.board_components_path(board)).to eq('/metrics/components/boards/101')
  end

  it "defines #board_api_path" do
    expect(helper.board_api_path(board)).to eq('/metrics/api/boards/101')
  end

  it "defines #issue_path" do
    expect(helper.issue_path(project)).to eq('/metrics/domain/boards/101/issues/DELIVERY-1')
  end

  it "defines #path_for" do
    expect(helper.path_for(project)).to eq('/metrics/domain/boards/101/issues/DELIVERY-1')
  end
end