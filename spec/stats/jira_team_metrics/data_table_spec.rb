require 'rails_helper'

RSpec.describe JiraTeamMetrics::DataTable do
  let(:columns) { ['issue_key', 'issue_type', 'developer', 'cycle_time'] }

  let(:rows) {[
    ['DEV-100', 'Story', 'Joe', 3],
    ['DEV-101', 'Bug', 'Anne', 2],
    ['DEV-102', 'Story', nil, nil],
    ['DEV-103', 'Story', 'Anne', 4],
    ['DEV-104', 'Story', 'Joe', 1]
  ]}

  let(:data_table) { JiraTeamMetrics::DataTable.new(columns, rows) }

  describe "#initialize" do
    it "initializes the rows and columns" do
      expect(data_table.columns).to eq(columns)
      expect(data_table.rows).to eq(rows)
    end
  end

  describe "#group_by" do
    it "aggregates rows by the given column" do
      grouped_data = data_table.group_by('issue_type', :count, of: 'issue_key', as: 'Count')
      expect(grouped_data.columns).to eq(['issue_type', 'Count'])
      expect(grouped_data.rows).to eq([
        ['Story', 4],
        ['Bug', 1]
      ])
    end

    it "aggregates based on compacted values" do
      grouped_data = data_table.group_by('issue_type', :count, of: 'developer', as: 'Count')
      expect(grouped_data.columns).to eq(['issue_type', 'Count'])
      expect(grouped_data.rows).to eq([
        ['Story', 3],
        ['Bug', 1]
      ])
    end

    it "aggregates based on the given function" do
      grouped_data = data_table.group_by('issue_type', :sum, of: 'cycle_time', as: 'Sum')
      expect(grouped_data.columns).to eq(['issue_type', 'Sum'])
      expect(grouped_data.rows).to eq([
        ['Story', 8],
        ['Bug', 2]
      ])
    end

    it "aggregates by multiple columns" do
      grouped_data = data_table.group_by(['issue_type', 'developer'], :count, of: 'issue_key', as: 'Count')
      expect(grouped_data.columns).to eq(['issue_type', 'developer', 'Count'])
      expect(grouped_data.rows).to eq([
        ['Story', 'Joe', 2],
        ['Bug', 'Anne', 1],
        ['Story', nil, 1],
        ['Story', 'Anne', 1]
      ])
    end

    it "aggregates by a custom block" do
      grouped_data = data_table.group_by(['issue_type', 'developer'], :count, of: 'issue_key', as: 'Count') do |issue_type, developer|
        [issue_type.try(:downcase), developer.try(:downcase)]
      end
      expect(grouped_data.columns).to eq(['issue_type', 'developer', 'Count'])
      expect(grouped_data.rows).to eq([
        ['story', 'joe', 2],
        ['bug', 'anne', 1],
        ['story', nil, 1],
        ['story', 'anne', 1]
      ])
    end
  end

  describe "#pivot_on" do
    let(:grouped_data) {
      data_table.group_by(['issue_type', 'developer'], :count, of: 'issue_key', as: 'Count')
    }

    it "creates a pivot table based on the given columns" do
      pivot_data = grouped_data.pivot_on('developer', select: 'Count')
      expect(pivot_data.columns).to eq(['issue_type', 'Joe', 'Anne', nil])
      expect(pivot_data.rows).to eq([
        ['Story', 2, 1, 1],
        ['Bug', nil, 1, nil]
      ])
    end

    it "sets nil values to if_nil if given" do
      pivot_data = grouped_data.pivot_on('developer', select: 'Count', if_nil: 0)
      expect(pivot_data.columns).to eq(['issue_type', 'Joe', 'Anne', nil])
      expect(pivot_data.rows).to eq([
        ['Story', 2, 1, 1],
        ['Bug', 0, 1, 0]
      ])
    end
  end

  describe "#sort_by" do
    it "sorts by the given column" do
      sorted_data = data_table.sort_by('cycle_time')
      expect(sorted_data.rows).to eq([
        ['DEV-102', 'Story', nil, nil],
        ['DEV-104', 'Story', 'Joe', 1],
        ['DEV-101', 'Bug', 'Anne', 2],
        ['DEV-100', 'Story', 'Joe', 3],
        ['DEV-103', 'Story', 'Anne', 4]
      ])
    end
  end

  describe "#reverse" do
    it "slips the order" do
      sorted_data = data_table.sort_by('cycle_time').reverse
      expect(sorted_data.rows).to eq([
        ['DEV-103', 'Story', 'Anne', 4],
        ['DEV-100', 'Story', 'Joe', 3],
        ['DEV-101', 'Bug', 'Anne', 2],
        ['DEV-104', 'Story', 'Joe', 1],
        ['DEV-102', 'Story', nil, nil]
      ])
    end
  end

  describe "#to_json" do
    it "returns a json representation for google charts" do
      json = data_table.to_json
      expect(json).to eq({
        'cols' => [
          { 'label' => 'issue_key', 'type' => 'string' },
          { 'label' => 'issue_type', 'type' => 'string' },
          { 'label' => 'developer', 'type' => 'string' },
          { 'label' => 'cycle_time', 'type' => 'number' }
        ],
        'rows' => [
          {
            'c' => [
              { 'v' => 'DEV-100' },
              { 'v' => 'Story' },
              { 'v' => 'Joe' },
              { 'v' => 3 }
            ]
          },
          {
            'c' => [
              { 'v' => 'DEV-101' },
              { 'v' => 'Bug' },
              { 'v' => 'Anne' },
              { 'v' => 2 }
            ]
          },
          {
            'c' => [
              { 'v' => 'DEV-102' },
              { 'v' => 'Story' },
              { 'v' => nil },
              { 'v' => nil }
            ]
          },
          {
            'c' => [
              { 'v' => 'DEV-103' },
              { 'v' => 'Story' },
              { 'v' => 'Anne' },
              { 'v' => 4 }
            ]
          },
          {
            'c' => [
              { 'v' => 'DEV-104' },
              { 'v' => 'Story' },
              { 'v' => 'Joe' },
              { 'v' => 1 }
            ]
          }
        ]
      })
    end
  end
end