require 'rails_helper'

RSpec.describe JiraTeamMetrics::ConfigFileService do
  describe "#load_config" do
    context "when given a valid path and file" do
      let(:config_path) { File.absolute_path("#{fixture_path}/valid_config.yml") }

      it "loads and sets the domain config" do
        service = JiraTeamMetrics::ConfigFileService.new(config_path, fixture_path)
        service.load_config
        expect(service.domain.config.url).to eq('https://jira.valid_config.example.com')
      end
    end

    context "when given a valid path with an invalid file" do
      let(:config_path) { "#{fixture_path}/invalid_config.yml" }

      it "loads and sets the domain config" do
        service = JiraTeamMetrics::ConfigFileService.new(config_path, nil)
        expect { service.load_config }.to raise_error(RuntimeError, /Invalid config: Config expected Hash to have key: 'url'/)
      end
    end

    context "when given a file that does not exist" do
      it "does nothing" do
        service = JiraTeamMetrics::ConfigFileService.new('', nil)
        expect(service.domain).not_to receive(:config_string=)
        service.load_config
      end
    end
  end
end
