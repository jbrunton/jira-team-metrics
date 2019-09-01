require 'rails_helper'

RSpec.describe JiraTeamMetrics::ConfigFileService do
  let(:domain) { create(:domain) }
  let(:config_path) { File.absolute_path(fixture_path) }

  describe "#load_config" do
    context "when given a valid path and file" do
      it "loads and sets the domain config" do
        service = JiraTeamMetrics::ConfigFileService.new('valid_config.yml', config_path)
        service.load_config(domain)
        expect(domain.config.url).to eq('https://jira.valid_config.example.com')
      end
    end

    context "when given a valid path with an invalid file" do
      it "Raises an error" do
        service = JiraTeamMetrics::ConfigFileService.new('invalid_config.yml', config_path)
        expect { service.load_config(domain) }.to raise_error(RuntimeError, "Invalid config: Config Invalid type for field 'url': expected String but was NilClass")
      end
    end

    context "when given a file that does not exist" do
      it "Raises an error" do
        service = JiraTeamMetrics::ConfigFileService.new('not_a_file.yml', config_path)
        expect { service.load_config(domain) }.to raise_error(RuntimeError, /Invalid config: .*not_a_file.yml does not exist./)
      end
    end

    context "when given a nil file_name" do
      it "does nothing" do
        service = JiraTeamMetrics::ConfigFileService.new(nil, 'invalid/directory/')
        expect(domain).not_to receive(:config_string=)
        service.load_config(domain)
      end
    end
  end
end
