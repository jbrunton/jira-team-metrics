require 'rails_helper'

RSpec.describe BoardConfig do
  let(:default_query) { "not (filter = 'Outliers')" }

  let(:config_hash) do
    {
      'default_query' => default_query
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
end