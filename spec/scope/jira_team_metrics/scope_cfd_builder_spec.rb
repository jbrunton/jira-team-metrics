require 'rails_helper'

RSpec.describe JiraTeamMetrics::ScopeCfdBuilder do
  let(:today) { DateTime.new(2018, 6, 1) }

  let(:issue1) { create(:issue, started_time: DateTime.new(2018, 4, 1), completed_time: DateTime.new(2018, 4, 3, 10)) }
  let(:issue2) { create(:issue, started_time: DateTime.new(2018, 4, 2), completed_time: DateTime.new(2018, 4, 4, 10)) }
  let(:issue3) { create(:issue, started_time: DateTime.new(2018, 8, 1)) }
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
end