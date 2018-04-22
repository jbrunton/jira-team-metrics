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

      it "aggregates by a custom block" do
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
          .pivot('issue_key', for: 'developer', in: ['Joe', 'Anne', nil])

        expect(pivot_data.columns).to eq(['issue_type', 'Joe', 'Anne', nil])
        expect(pivot_data.rows).to eq([
          ['Story', 2, 1, 1],
          ['Bug', 0, 1, 0]
        ])
      end
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
      pivot_data = grouped_data.pivot_on('developer', from: ['Joe', 'Anne', nil], select: 'Count')
      expect(pivot_data.columns).to eq(['issue_type', 'Joe', 'Anne', nil])
      expect(pivot_data.rows).to eq([
        ['Story', 2, 1, 1],
        ['Bug', nil, 1, nil]
      ])
    end

    it "creates a pivot table based on the given column order" do
      pivot_data = grouped_data.pivot_on('developer', from: ['Anne', 'Joe', nil], select: 'Count')
      expect(pivot_data.columns).to eq(['issue_type', 'Anne', 'Joe', nil])
      expect(pivot_data.rows).to eq([
        ['Story', 1, 2, 1],
        ['Bug', 1, nil, nil]
      ])
    end

    it "sets nil values to if_nil if given" do
      pivot_data = grouped_data.pivot_on('developer', from: ['Joe', 'Anne', nil], select: 'Count', if_nil: 0)
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