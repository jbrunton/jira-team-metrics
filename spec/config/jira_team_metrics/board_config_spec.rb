require 'rails_helper'

RSpec.describe JiraTeamMetrics::BoardConfig do
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

  let(:domain) do
    create(:domain, config_string: <<~EOF
      url: example.com
      reports:
        epics:
          sections:
            - title: 'Domain In Progress'
              mql: status = 'In Progress'
        projects:
          sections:
            - title: 'Domain In Progress'
              mql: status = 'In Progress'
        scatterplot:
          default_query: domain scatterplot default query
        throughput:
          default_query: domain throughput default query
        aging_wip:
          completed_query: domain aging_wip completed query
    EOF
    )
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

    it "returns jql filters if specified" do
      config_hash['filters'] = [{
        'name' => 'Releases',
        'jql' => "summary ~ 'Release'"
      }]
      board_config = JiraTeamMetrics::BoardConfig.new(config_hash)
      expect(board_config.filters).to eq([
        JiraTeamMetrics::BoardConfig::JqlFilter.new('Releases', "summary ~ 'Release'")
      ])
    end

    it "returns mql filters if specified" do
      config_hash['filters'] = [{
        'name' => 'Completed',
        'mql' => "status_category = 'Done'"
      }]
      board_config = JiraTeamMetrics::BoardConfig.new(config_hash)
      expect(board_config.filters).to eq([
        JiraTeamMetrics::BoardConfig::MqlFilter.new('Completed', "status_category = 'Done'")
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

    context "#timesheets_config" do
      it "returns nil if no details are given" do
        board_config = JiraTeamMetrics::BoardConfig.new(config_hash)
        expect(board_config.timesheets_config).to eq(nil)
      end

      it "returns timesheets config when specified" do
        config_hash['timesheets'] = {
          'reporting_period' => {
            'day_of_week' => 2,
            'duration' => {
              'days' => 7
            }
          }
        }
        board_config = JiraTeamMetrics::BoardConfig.new(config_hash)
        expect(board_config.timesheets_config).to eq(JiraTeamMetrics::BoardConfig::TimesheetsConfig.new(2, 7, []))
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

  context "#epics_report_options" do
    it "returns an array of sections when defined" do
      board_config = JiraTeamMetrics::BoardConfig.new(config_hash)
      expected_options = JiraTeamMetrics::BaseConfig::ReportOptions.new(
          [
              JiraTeamMetrics::BaseConfig::ReportSection.new(
                  'Board In Progress',
                  "status = 'In Progress'"
              )
          ]
      )


      actual_options = board_config.epics_report_options(domain)

      expect(actual_options).to eq(expected_options)
    end

    it "returns the domain sections when not defined" do
      config_hash['reports'].delete('epics')
      board_config = JiraTeamMetrics::BoardConfig.new(config_hash)
      expected_options = JiraTeamMetrics::BaseConfig::ReportOptions.new(
          [
              JiraTeamMetrics::BaseConfig::ReportSection.new(
                  'Domain In Progress',
                  "status = 'In Progress'"
              )
          ]
      )

      actual_options = board_config.epics_report_options(domain)

      expect(actual_options).to eq(expected_options)
    end
  end

  context "#scatterplot_default_query" do
    it "returns the scatterplot default query for the board if given" do
      board_config = JiraTeamMetrics::BoardConfig.new(config_hash)
      expect(board_config.scatterplot_default_query(domain)).to eq('board scatterplot default query')
    end

    it "returns the scatterplot default query for the domain otherwise " do
      config_hash['reports'].delete('scatterplot')
      board_config = JiraTeamMetrics::BoardConfig.new(config_hash)

      board_config.validate

      expect(board_config.scatterplot_default_query(domain)).to eq('domain scatterplot default query')
    end
  end

  context "#throughput_default_query" do
    it "returns the scatterplot default query for the board if given" do
      board_config = JiraTeamMetrics::BoardConfig.new(config_hash)
      expect(board_config.throughput_default_query(domain)).to eq('board throughput default query')
    end

    it "returns the throughput default query for the domain otherwise " do
      config_hash['reports'].delete('throughput')
      board_config = JiraTeamMetrics::BoardConfig.new(config_hash)

      board_config.validate

      expect(board_config.throughput_default_query(domain)).to eq('domain throughput default query')
    end
  end

  context "#aging_wip_completed_query" do
    it "returns the aging WIP completed query" do
      board_config = JiraTeamMetrics::BoardConfig.new(config_hash)
      expect(board_config.aging_wip_completed_query(domain)).to eq('board aging_wip completed query')
    end

    it "is optional" do
      config_hash['reports'].delete('aging_wip')
      board_config = JiraTeamMetrics::BoardConfig.new(config_hash)

      board_config.validate

      expect(board_config.aging_wip_completed_query(domain)).to eq('domain aging_wip completed query')
    end
  end
end