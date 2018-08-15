require 'rails_helper'

RSpec.describe JiraTeamMetrics::ScopeCfdBuilder do
  let(:today) { DateTime.new(2018, 4, 8) }

  before(:each) { travel_to today }

  let(:issue1) { create(:issue, started_time: DateTime.new(2018, 4, 1), completed_time: DateTime.new(2018, 4, 3, 10, 30)) }
  let(:issue2) { create(:issue, started_time: DateTime.new(2018, 4, 2), completed_time: DateTime.new(2018, 4, 4, 10, 30)) }
  let(:issue3) { create(:issue, started_time: DateTime.new(2018, 4, 3)) }
  let(:issue4) { create(:issue) }


  context "when no remaining scope is given" do
    let(:scope) { [issue1, issue2] }

    it "builds a CFD spanning the start and end dates with a buffer of 2 days" do
      builder = JiraTeamMetrics::ScopeCfdBuilder.new(scope, 7)
      data = builder.build
      expect(data).to eq([
        [{"label"=>"Date", "type"=>"date", "role"=>"domain"}, {"role"=>"annotation"}, "Done", {"role"=>"annotation"}, {"role"=>"annotationText"}, "In Progress", "To Do", "Predicted"],
        ["Date(2018, 2, 30, 0, 0)", nil, 0, nil, nil, 0, 0, 0],
        ["Date(2018, 2, 31, 0, 0)", nil, 0, nil, nil, 0, 1, 0],
        ["Date(2018, 3, 1, 0, 0)", nil, 0, nil, nil, 0, 2, 0],
        ["Date(2018, 3, 2, 0, 0)", nil, 0, nil, nil, 1, 1, 0],
        ["Date(2018, 3, 3, 0, 0)", nil, 0, nil, nil, 2, 0, 0],
        ["Date(2018, 3, 4, 0, 0)", nil, 1, nil, nil, 1, 0, 0],
        ["Date(2018, 3, 5, 0, 0)", nil, 2, nil, nil, 0, 0, 0],
        ["Date(2018, 3, 6, 0, 0)", nil, 2, nil, nil, 0, 0, 0]])
    end
  end

  context "when some scope is remaining" do
    let(:scope) { [issue1, issue2, issue3] }

    it "builds a CFD with a predicted forecast" do
      builder = JiraTeamMetrics::ScopeCfdBuilder.new(scope, 7)
      data = builder.build
      expect(data).to eq([
        [{"label"=>"Date", "type"=>"date", "role"=>"domain"}, {"role"=>"annotation"}, "Done", {"role"=>"annotation"}, {"role"=>"annotationText"}, "In Progress", "To Do", "Predicted"],
        ["Date(2018, 3, 1, 0, 0)", nil, 0, nil, nil, 0, 2, 0],
        ["Date(2018, 3, 2, 0, 0)", nil, 0, nil, nil, 1, 2, 0],
        ["Date(2018, 3, 3, 0, 0)", nil, 0, nil, nil, 2, 1, 0],
        ["Date(2018, 3, 4, 0, 0)", nil, 1, nil, nil, 2, 0, 0],
        ["Date(2018, 3, 5, 0, 0)", nil, 2, nil, nil, 1, 0, 0],
        ["Date(2018, 3, 6, 0, 0)", nil, 2, nil, nil, 1, 0, 0],
        ["Date(2018, 3, 7, 0, 0)", nil, 2, nil, nil, 1, 0, 0],
        ["Date(2018, 3, 8, 0, 0)", nil, 2, nil, nil, 1, 0, 0],
        ["Date(2018, 3, 9, 0, 0)", nil, 2.2857142857142856, nil, nil, 0.7142857142857143, 0, 0],
        ["Date(2018, 3, 10, 0, 0)", nil, 2.571428571428571, nil, nil, 0.4285714285714286, 0, 0],
        ["Date(2018, 3, 11, 0, 0)", nil, 2.857142857142857, nil, nil, 0.1428571428571429, 0, 0],
        ["Date(2018, 3, 12, 0, 0)", nil, 3, nil, nil, 0, 0, 0],
        ["Date(2018, 3, 13, 0, 0)", nil, 3, nil, nil, 0, 0, 0],
        ["Date(2018, 3, 8)", "today", nil, nil, nil, nil, nil, nil],
        ["Date(2018, 3, 11, 12, 0)", "forecast", nil, nil, nil, nil, nil, nil]
      ])
    end
  end
end