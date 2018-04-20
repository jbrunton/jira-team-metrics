require 'rails_helper'

RSpec.describe JiraTeamMetrics::DataTableBuilder do
  let(:issues) {[
    build(:issue, key: 'DEV-100'),
    build(:issue, key: 'DEV-101')
  ]}

  describe "#build" do
    it "builds a data table based on the given data and methods" do
      data_table = JiraTeamMetrics::DataTableBuilder.new
        .data(issues)
        .pick(:key)
        .build
      expect(data_table.columns).to eq(['key'])
      expect(data_table.rows).to eq([['DEV-100'], ['DEV-101']])
    end
  end
end