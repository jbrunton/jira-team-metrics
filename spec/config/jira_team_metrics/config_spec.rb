require 'rails_helper'

RSpec.describe JiraTeamMetrics::Config do
  let(:default_query) { "not (filter = 'Outliers')" }
  let(:board_reports) do
    {
      'epics' => {
        'sections' => [
          {
            'title' => 'Board In Progress',
            'mql' => "status = 'In Progress'"
          }
        ]
      },
      'projects' => {
        'sections' => [
          {
            'title' => 'Board In Progress',
            'mql' => "status = 'In Progress'"
          }
        ]
      },
      'scatterplot' => {
        'default_query' => 'board scatterplot default query'
      },
      'throughput' => {
        'default_query' => 'board throughput default query'
      },
      'aging_wip' => {
        'completed_query' => 'board aging_wip completed query'
      }
    }
  end

  let(:config_hash) do
    {
      'default_query' => default_query,
      'reports' => board_reports
    }
  end

  it "initializes #config_hash" do
    config = JiraTeamMetrics::Config.new(config_hash, 'board_config')
    expect(config.config_hash).to eq(config_hash)
  end

  context "#validate" do
    it "validates a well formed config" do
      config = JiraTeamMetrics::Config.new(config_hash, 'board_config')
      expect { config.validate }.not_to raise_error
    end

    it "validates the top level fields" do
      config_hash['unexpected_field'] = 'foo'
      config = JiraTeamMetrics::Config.new(config_hash, 'board_config')
      expect { config.validate }.to raise_error(Rx::ValidationError, /Hash had extra keys/)
    end
  end
end
