require 'rails_helper'

RSpec.describe JiraTeamMetrics::PathHelper do
  before(:each) { helper.define_singleton_method(:root_path) { '/metrics/' } }

  let(:board) { create(:board, jira_id: 101) }
  let(:delivery) { board.issues.create(attributes_for(:issue, key: 'DELIVERY-1')) }

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

  it "defines #deliveries_report_path" do
    expect(helper.deliveries_report_path(board)).to eq('/metrics/reports/boards/101/deliveries')
  end

  it "defines #delivery_report_path" do
    expect(helper.delivery_report_path(board, delivery)).to eq('/metrics/reports/boards/101/deliveries/DELIVERY-1')
  end

  it "defines #delivery_scope_report_path" do
    expect(helper.delivery_scope_report_path(board, delivery, 'MyTeam')).to eq('/metrics/reports/boards/101/deliveries/DELIVERY-1/scope/MyTeam')
  end

  it "defines #delivery_throughput_report_path" do
    expect(helper.delivery_throughput_report_path(board, delivery, 'MyTeam')).to eq('/metrics/reports/boards/101/deliveries/DELIVERY-1/throughput/MyTeam')
  end

  it "defines #timesheets_report_path" do
    expect(helper.timesheets_report_path(board)).to eq('/metrics/reports/boards/101/timesheets')
  end

  it "defines #board_components_path" do
    expect(helper.board_components_path(board)).to eq('/metrics/components/boards/101')
  end

  it "defines #board_api_path" do
    expect(helper.board_api_path(board)).to eq('/metrics/api/boards/101')
  end

  it "defines #issue_path" do
    expect(helper.issue_path(delivery)).to eq('/metrics/domain/boards/101/issues/DELIVERY-1')
  end

  it "defines #path_for" do
    expect(helper.path_for(delivery)).to eq('/metrics/domain/boards/101/issues/DELIVERY-1')
  end
end