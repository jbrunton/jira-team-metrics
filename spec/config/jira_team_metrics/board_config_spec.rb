require 'rails_helper'

RSpec.describe JiraTeamMetrics::BoardConfig do
  let(:default_query) { "not (filter = 'Outliers')" }

  let(:sync) {
    {
      'since' => '-30d',
      'subquery' => 'and not filter = MyFilter'
    }
  }

  let(:config_hash) do
    {
      'default_query' => default_query
    }
  end

  it "initializes #config_hash" do
    board_config = JiraTeamMetrics::BoardConfig.new(config_hash)
    expect(board_config.config_hash).to eq(config_hash)
  end

  context "#validate" do
    it "validates a well formed config" do
      board_config = JiraTeamMetrics::BoardConfig.new(config_hash)
      expect { board_config.validate }.not_to raise_error
    end

    it "validates the top level fields" do
      config_hash['unexpected_field'] = 'foo'
      board_config = JiraTeamMetrics::BoardConfig.new(config_hash)
      expect { board_config.validate }.to raise_error(Rx::ValidationError, /Hash had extra keys/)
    end
  end

  context "#default_query" do
    it "returns the default query in the config" do
      board_config = JiraTeamMetrics::BoardConfig.new(config_hash)
      expect(board_config.default_query).to eq(default_query)
    end

    it "returns a blank default query if none is specified" do
      config_hash.delete('default_query')
      board_config = JiraTeamMetrics::BoardConfig.new(config_hash)
      expect(board_config.default_query).to eq('')
    end
  end

  context "#filters" do
    it "returns empty if none are specified" do
      board_config = JiraTeamMetrics::BoardConfig.new(config_hash)
      expect(board_config.filters).to eq([])
    end

    it "returns query filters if specified" do
      config_hash['filters'] = [{
        'name' => 'Releases',
        'query' => "summary ~ 'Release'"
      }]
      board_config = JiraTeamMetrics::BoardConfig.new(config_hash)
      expect(board_config.filters).to eq([
        JiraTeamMetrics::BoardConfig::QueryFilter.new('Releases', "summary ~ 'Release'")
      ])
    end

    it "returns config filters if specified" do
      config_hash['filters'] = [{
        'name' => 'Support Tickets',
        'issues' => ['ENG-101']
      }]
      board_config = JiraTeamMetrics::BoardConfig.new(config_hash)
      expect(board_config.filters).to eq([
        JiraTeamMetrics::BoardConfig::ConfigFilter.new('Support Tickets', ['ENG-101'])
      ])
    end

    context "#predictive_scope" do
      it "returns returns nil if no details are given" do
        board_config = JiraTeamMetrics::BoardConfig.new(config_hash)
        expect(board_config.predictive_scope).to eq(nil)
      end

      it "returns predictive scope details when specified" do
        config_hash['predictive_scope'] = {
          'board_id' => 123,
          'adjustments_field' => 'Predictive Adjustments'
        }
        board_config = JiraTeamMetrics::BoardConfig.new(config_hash)
        expect(board_config.predictive_scope).to eq(JiraTeamMetrics::BoardConfig::PredictiveScope.new(123, 'Predictive Adjustments'))
      end
    end

    context "#sync_months" do
      it "returns nil if no sync options are given" do
        board_config = JiraTeamMetrics::BoardConfig.new(config_hash)
        expect(board_config.sync_months).to eq(nil)
      end

      it "returns the number of months to sync when specified" do
        config_hash['sync'] = {
          'months' => 6
        }
        board_config = JiraTeamMetrics::BoardConfig.new(config_hash)
        expect(board_config.sync_months).to eq(6)
      end
    end
  end
end