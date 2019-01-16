require 'rails_helper'

RSpec.describe JiraTeamMetrics::DomainConfig do
  let(:custom_fields) { ['My Field'] }
  let(:domain_url) { 'https://jira.example.com' }
  let(:domain_name) { 'My Domain' }

  let(:board_id) { 123 }
  let(:board_config_file) { 'valid_config.yml' }
  let(:boards) do
    [{
      'board_id' => board_id,
      'config_file' => board_config_file
    }]
  end
  let(:teams) do
    [{
      'name' => 'Data & Analytics',
      'short_name' => 'dat'
    }]
  end
  let(:reports) do
    {
      'epics' => {
        'sections' => [
          {
            'title' => 'In Progress',
            'mql' => "status = 'In Progress'"
          }
        ],
        'backing_query' => 'epics backing query',
        'card_layout' => {
          'fields' => ['Product Owner']
        }
      },
      'projects' => {
        'sections' => [
          {
            'title' => 'In Progress',
            'mql' => "status = 'In Progress'"
          }
        ],
        'backing_query' => 'projects backing query',
        'card_layout' => {
          'fields' => ['Product Owner']
        }
      },
      'scatterplot' => {
        'default_query' => 'scatterplot default query'
      },
      'throughput' => {
        'default_query' => 'throughput default query'
      },
      'aging_wip' => {
        'completed_query' => 'aging_wip completed query'
      }
    }
  end

  let(:config_hash) do
    {
      'fields' => custom_fields,
      'url' => domain_url,
      'name' => domain_name,
      'boards' => boards,
      'teams' => teams,
      'reports' => reports
    }
  end

  it "initializes #config_hash" do
    domain_config = JiraTeamMetrics::DomainConfig.new(config_hash)
    expect(domain_config.config_hash).to eq(config_hash)
  end

  context "#validate" do
    it "validates a well formed config" do
      domain_config = JiraTeamMetrics::DomainConfig.new(config_hash)
      expect { domain_config.validate }.not_to raise_error
    end

    it "validates the top level fields" do
      config_hash['unexpected_field'] = 'foo'
      domain_config = JiraTeamMetrics::DomainConfig.new(config_hash)
      expect { domain_config.validate }.to raise_error(Rx::ValidationError, /Hash had extra keys/)
    end

    it "validates the type of the fields attribute" do
      config_hash['fields'] = [1, 2]
      domain_config = JiraTeamMetrics::DomainConfig.new(config_hash)
      expect { domain_config.validate }.to raise_error(Rx::ValidationError, /expected String got 1/)
    end

    it "requires a url" do
      config_hash.delete('url')
      domain_config = JiraTeamMetrics::DomainConfig.new(config_hash)
      expect { domain_config.validate }.to raise_error(Rx::ValidationError, /expected Hash to have key: 'url'/)
    end
  end

  context "#url" do
    it "returns the url" do
      domain_config = JiraTeamMetrics::DomainConfig.new(config_hash)
      expect(domain_config.url).to eq(domain_url)
    end

    it "returns <Unconfigured Domain> if no url is specified" do
      config_hash.delete('url')
      domain_config = JiraTeamMetrics::DomainConfig.new(config_hash)
      expect(domain_config.url).to eq('<Unconfigured Domain>')
    end
  end

  context "#name" do
    it "returns the specified name" do
      domain_config = JiraTeamMetrics::DomainConfig.new(config_hash)
      expect(domain_config.name).to eq(domain_name)
    end

    it "returns the url if no name is given" do
      config_hash.delete('name')
      domain_config = JiraTeamMetrics::DomainConfig.new(config_hash)
      expect(domain_config.name).to eq(domain_url)
    end
  end

  context "#fields" do
    it "returns the fields in the config" do
      domain_config = JiraTeamMetrics::DomainConfig.new(config_hash)
      expect(domain_config.fields).to eq(custom_fields)
    end

    it "returns an empty array if no custom fields are specified" do
      config_hash.delete('fields')
      domain_config = JiraTeamMetrics::DomainConfig.new(config_hash)
      expect(domain_config.fields).to eq([])
    end
  end

  context "#boards" do
    it "is optional" do
      config_hash.delete('boards')
      domain_config = JiraTeamMetrics::DomainConfig.new(config_hash)
      domain_config.validate
    end

    it "returns the board configs" do
      domain_config = JiraTeamMetrics::DomainConfig.new(config_hash)
      expect(domain_config.boards).to eq([
        JiraTeamMetrics::DomainConfig::BoardDetails.new(board_id, board_config_file)
      ])
    end
  end

  context "#teams" do
    it "returns the given teams" do
      domain_config = JiraTeamMetrics::DomainConfig.new(config_hash)
      expect(domain_config.teams).to eq([
        JiraTeamMetrics::DomainConfig::TeamDetails.new('Data & Analytics', 'dat')
      ])
    end

    it "returns an empty array if no teams are given" do
      config_hash.delete('teams')
      domain_config = JiraTeamMetrics::DomainConfig.new(config_hash)
      expect(domain_config.teams).to eq([])
    end
  end

  context "#epics_report_options" do
    it "is optional" do
      config_hash['reports'].delete('epics')
      domain_config = JiraTeamMetrics::DomainConfig.new(config_hash)

      domain_config.validate

      expect(domain_config.epics_report_options.sections).to eq([])
    end

    it "returns an array of sections when defined" do
      domain_config = JiraTeamMetrics::DomainConfig.new(config_hash)
      expect(domain_config.epics_report_options).to eq(
          JiraTeamMetrics::BaseConfig::ReportOptions.new(
              [
                  JiraTeamMetrics::BaseConfig::ReportSection.new(
                      'In Progress',
                      "status = 'In Progress'"
                  )
              ],
              'epics backing query',
              JiraTeamMetrics::BaseConfig::CardLayout.new(['Product Owner'])
          )
      )
    end
  end

  context "#projects_report_options" do
    it "is optional" do
      config_hash['reports'].delete('projects')
      domain_config = JiraTeamMetrics::DomainConfig.new(config_hash)

      domain_config.validate

      expect(domain_config.projects_report_options.sections).to eq([])
    end

    it "returns an array of sections when defined" do
      domain_config = JiraTeamMetrics::DomainConfig.new(config_hash)
      expect(domain_config.projects_report_options).to eq(
          JiraTeamMetrics::BaseConfig::ReportOptions.new(
              [
                  JiraTeamMetrics::BaseConfig::ReportSection.new(
                      'In Progress',
                      "status = 'In Progress'"
                  )
              ],
              'projects backing query',
            JiraTeamMetrics::BaseConfig::CardLayout.new(['Product Owner'])
          )
      )
    end
  end

  context "#scatterplot_default_query" do
    it "returns the default scatterplot query" do
      domain_config = JiraTeamMetrics::DomainConfig.new(config_hash)
      expect(domain_config.scatterplot_default_query).to eq('scatterplot default query')
    end

    it "is optional" do
      config_hash['reports'].delete('scatterplot')
      domain_config = JiraTeamMetrics::DomainConfig.new(config_hash)

      domain_config.validate

      expect(domain_config.scatterplot_default_query).to eq(nil)
    end
  end

  context "#throughput_default_query" do
    it "returns the default scatterplot query" do
      domain_config = JiraTeamMetrics::DomainConfig.new(config_hash)
      expect(domain_config.throughput_default_query).to eq('throughput default query')
    end

    it "is optional" do
      config_hash['reports'].delete('throughput')
      domain_config = JiraTeamMetrics::DomainConfig.new(config_hash)

      domain_config.validate

      expect(domain_config.throughput_default_query).to eq(nil)
    end
  end

  context "#aging_wip_completed_query" do
    it "returns the aging WIP completed query" do
      domain_config = JiraTeamMetrics::DomainConfig.new(config_hash)
      expect(domain_config.aging_wip_completed_query).to eq('aging_wip completed query')
    end

    it "is optional" do
      config_hash['reports'].delete('aging_wip')
      domain_config = JiraTeamMetrics::DomainConfig.new(config_hash)

      domain_config.validate

      expect(domain_config.aging_wip_completed_query).to eq(nil)
    end
  end
end