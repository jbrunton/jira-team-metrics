require 'rails_helper'

RSpec.describe JiraTeamMetrics::ConfigFileService do
  let(:domain) { JiraTeamMetrics::Domain.get_instance }

  describe "#load_config" do
    context "when given a valid path and file" do
      let(:config_path) { "#{fixture_path}/valid_config.yml" }

      it "loads and sets the domain config" do
        service = JiraTeamMetrics::ConfigFileService.new(config_path)
        service.load_config
        expect(JiraTeamMetrics::Domain.get_instance.config.url).to eq('https://jira.valid_config.example.com')
      end
    end

    context "when given a valid path with an invalid file" do
      let(:config_path) { "#{fixture_path}/invalid_config.yml" }

      it "loads and sets the domain config" do
        service = JiraTeamMetrics::ConfigFileService.new(config_path)
        expect { service.load_config }.to raise_error(RuntimeError, /Invalid config: Config expected Hash to have key: 'url'/)
      end
    end

    context "when given a blank path" do
      let(:config_path) { '' }

      it "does nothing" do
        service = JiraTeamMetrics::ConfigFileService.new(config_path)
        expect(service.domain).not_to receive(:config_string=)
        service.load_config
      end
    end
  end
end
