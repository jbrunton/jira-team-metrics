require 'rails_helper'

RSpec.describe Board do
  let(:board) { create(:board) }

  describe "::DEFAULT_CONFIG" do
    before(:each) { board.config = Board::DEFAULT_CONFIG }

    it "specifies cycle_times properties" do
      expect(board.config_property('cycle_times.in_progress')).to eq({
        from: 'In Progress',
        to: 'Done'
      })
      expect(board.config_property('cycle_times.in_review')).to eq({
        from: 'In Review',
        to: 'In Test'
      })
      expect(board.config_property('cycle_times.in_test')).to eq({
        from: 'In Test',
        to: 'Done'
      })
    end

    it "specifies an outliers filter" do
      expect(board.config_filters).to eq([{
        name: 'Outliers',
        issues: [
          { key: 'ENG-101', reason: 'blocked in test' }
        ]
      }])
    end

    it "specifies an default query" do
      default_query = board.config_property('default_query')
      expect(default_query).to eq("not filter = 'Outliers'")
    end
  end
end