require 'rails_helper'

RSpec.describe BoardConfig do
  let(:default_query) { "not (filter = 'Outliers')" }
  let(:cycle_times) {
    {
      'in_test' => {
        'from' => 'In Test',
        'to' => 'Done'
      },
      'in_review' => {
        'from' => 'Review',
        'to' => 'In Test'
      },
      'in_progress' => {
        'from' => 'In Progress',
        'to' => 'Done'
      }
    }
  }

  let(:config_hash) do
    {
      'default_query' => default_query,
      'cycle_times' => cycle_times
    }
  end

  it "initializes #config_hash" do
    board_config = BoardConfig.new(config_hash)
    expect(board_config.config_hash).to eq(config_hash)
  end

  context "#default_query" do
    it "returns the default query in the config" do
      board_config = BoardConfig.new(config_hash)
      expect(board_config.default_query).to eq(default_query)
    end

    it "returns a blank default query if none is specified" do
      config_hash.delete('default_query')
      board_config = BoardConfig.new(config_hash)
      expect(board_config.default_query).to eq('')
    end
  end

  context "#cycle_times" do
    it "returns cycle time states" do
      board_config = BoardConfig.new(config_hash)
      expect(board_config.cycle_times).to eq(cycle_times)
    end
  end
end