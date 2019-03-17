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

  describe "#eql?" do
    it "returns true if the rows and columns are the same" do
      data_table_2 = JiraTeamMetrics::DataTable.new(columns.clone, rows.clone)
      expect(data_table.eql?(data_table_2)).to eq(true)
    end

    it "returns false if the rows and columns are not the same" do
      columns = ['Issue Key', 'Issue Type', 'Developer', 'Cycle Time']
      data_table_2 = JiraTeamMetrics::DataTable.new(columns, rows.clone)
      expect(data_table.eql?(data_table_2)).to eq(false)
    end
  end

  describe "#select" do
    context "when given varargs" do
      it "returns a query selector for the given args" do
        selector = data_table.select('issue_type')
        expect(selector.data_table).to eq(data_table)
        expect(selector.columns).to eq({
          'issue_type' => {}
        })
      end
    end

    context "when given a hash" do
      it "returns a query selector for the given hash" do
        selector = data_table.select({
          'issue_type' => { op: :count, as: 'Count' }
        })
        expect(selector.data_table).to eq(data_table)
        expect(selector.columns).to eq({
          'issue_type' => { op: :count, as: 'Count' }
        })
      end
    end

    context "when given no args" do
      it "returns an empty selector" do
        selector = data_table.select
        expect(selector.data_table).to eq(data_table)
        expect(selector.columns).to eq({})
      end
    end
  end

  context "Selector" do
    describe "#count" do
      it "appends a count transformation" do
        selector = data_table.select.count('issue_type')
        expect(selector.columns).to eq({
          'issue_type' => { op: :count }
        })
      end

      it "appends a transformation with the given options" do
        selector = data_table.select.count('issue_type', as: 'Count')
        expect(selector.columns).to eq({
          'issue_type' => { op: :count, as: 'Count' }
        })
      end

      it "appends multiple transformation given an array" do
        selector = data_table.select.count(['issue_type', 'developer'])
        expect(selector.columns).to eq({
          'issue_type' => { op: :count },
          'developer' => { op: :count }
        })
      end
    end

    describe "#sum" do
      it "appends a sum transformation" do
        selector = data_table.select.sum('cycle_time')
        expect(selector.columns).to eq({
          'cycle_time' => { op: :sum }
        })
      end
    end

    describe "#group" do
      it "aggregates rows by the selected column" do
        grouped_data = data_table
          .select('issue_type').count('issue_key', as: 'Count')
          .group
        
        expect(grouped_data.columns).to eq(['issue_type', 'Count'])
        expect(grouped_data.rows).to eq([
          ['Story', 4],
          ['Bug', 1]
        ])
      end

      it "aggregates based on compacted values" do
        grouped_data = data_table
          .select('issue_type').count('developer', as: 'Count')
          .group

        expect(grouped_data.columns).to eq(['issue_type', 'Count'])
        expect(grouped_data.rows).to eq([
          ['Story', 3],
          ['Bug', 1]
        ])
      end

      it "aggregates based on the given function" do
        grouped_data = data_table
          .select('issue_type').sum('cycle_time', as: 'Sum')
          .group

        expect(grouped_data.columns).to eq(['issue_type', 'Sum'])
        expect(grouped_data.rows).to eq([
          ['Story', 8],
          ['Bug', 2]
        ])
      end

      it "aggregates by multiple columns" do
        grouped_data = data_table
          .select('issue_type', 'developer').count('issue_key', as: 'Count')
          .group

        expect(grouped_data.columns).to eq(['issue_type', 'developer', 'Count'])
        expect(grouped_data.rows).to eq([
          ['Story', 'Joe', 2],
          ['Bug', 'Anne', 1],
          ['Story', nil, 1],
          ['Story', 'Anne', 1]
        ])
      end

      it "aggregates by a single column with a custom block" do
        grouped_data = data_table
           .select('issue_type').count('issue_key', as: 'Count')
           .group { |issue_type| issue_type.try(:downcase) }

        expect(grouped_data.columns).to eq(['issue_type', 'Count'])
        expect(grouped_data.rows).to eq([
            ['story', 4],
            ['bug', 1]
        ])
      end

      it "aggregates by multiple columns with a custom block" do
        grouped_data = data_table
          .select('issue_type', 'developer').count('issue_key', as: 'Count')
          .group do |issue_type, developer|
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

    describe "#pivot" do
      it "creates a pivot table based on the given columns" do
        pivot_data = data_table.select('issue_type').count('Joe').count('Anne').count(nil)
          .pivot('issue_key', for: 'developer', in: ['Joe', 'Anne', nil], if_nil: 0)

        expect(pivot_data.columns).to eq(['issue_type', 'Joe', 'Anne', nil])
        expect(pivot_data.rows).to eq([
          ['Story', 2, 1, 1],
          ['Bug', 0, 1, 0]
        ])
      end
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

    it "sorts by the given block" do
      sorted_data = data_table.sort_by('cycle_time') { |ct| -ct }
      expect(sorted_data.rows).to eq([
        ['DEV-102', 'Story', nil, nil],
        ['DEV-103', 'Story', 'Anne', 4],
        ['DEV-100', 'Story', 'Joe', 3],
        ['DEV-101', 'Bug', 'Anne', 2],
        ['DEV-104', 'Story', 'Joe', 1]
      ])
    end
  end

  describe "#map" do
    it "transforms values in the column with the given block" do
      cycle_times_hours = data_table.map('cycle_time') { |t| t * 24 unless t.nil? }
      expect(cycle_times_hours.rows).to eq([
        ['DEV-100', 'Story', 'Joe', 72],
        ['DEV-101', 'Bug', 'Anne', 48],
        ['DEV-102', 'Story', nil, nil],
        ['DEV-103', 'Story', 'Anne', 96],
        ['DEV-104', 'Story', 'Joe', 24]
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

  describe "#insert_if_missing" do
    let(:indexes) { [0, 1, 2] }

    context "given an empty table" do
      let(:data_table) { JiraTeamMetrics::DataTable.new(['index', 'count'], []) }

      it "fills in the missing rows" do
        data_table.insert_if_missing(indexes, [0])
        expect(data_table.rows).to eq([
            [0, 0],
            [1, 0],
            [2, 0]])
      end
    end

    context "given a table with some existing values" do
      let(:data_table) do
        JiraTeamMetrics::DataTable.new(
            ['index', 'count'],
            [[1, 4]])
      end

      it "fills in the missing rows" do
        data_table.insert_if_missing(indexes, [0])
        expect(data_table.rows).to eq([
                                          [0, 0],
                                          [1, 4],
                                          [2, 0]])
      end
    end

    context "given a block that adjusts the inputs" do
      let(:data_table) do
        JiraTeamMetrics::DataTable.new(
            ['index', 'count'],
            [[0.1, 4], [3.9, 4]])
      end

      it "fills in the missing rows" do
        data_table.insert_if_missing([0, 2, 4], [0]) { |x| (x / 2.0).round * 2 }
        expect(data_table.rows).to eq([
                                          [0.1, 4],
                                          [2,   0],
                                          [3.9, 4]])
      end
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

  describe "#to_csv" do
    it "returns a CSV representation of the table" do
      expect(data_table.to_csv).to eq <<~CSV
        issue_key,issue_type,developer,cycle_time
        DEV-100,Story,Joe,3
        DEV-101,Bug,Anne,2
        DEV-102,Story,,
        DEV-103,Story,Anne,4
        DEV-104,Story,Joe,1
      CSV
    end
  end
end