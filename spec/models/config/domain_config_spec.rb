require 'rails_helper'

RSpec.describe DomainConfig do
  let(:custom_fields) { ['My Field'] }
  let(:domain_url) { 'https://jira.example.com' }
  let(:domain_name) { 'My Domain' }

  let(:board_id) { 123 }
  let(:board_config_url) { 'https://example.com/board-config.yml' }
  let(:boards) do
    [{
      'jira_id' => board_id,
      'config_url' => board_config_url
    }]
  end

  let(:config_hash) do
    {
      'fields' => custom_fields,
      'url' => domain_url,
      'name' => domain_name,
      'boards' => boards
    }
  end

  it "initializes #config_hash" do
    domain_config = DomainConfig.new(config_hash)
    expect(domain_config.config_hash).to eq(config_hash)
  end

  context "#validate" do
    it "validates a well formed config" do
      domain_config = DomainConfig.new(config_hash)
      expect { domain_config.validate }.not_to raise_error
    end

    it "validates the top level fields" do
      config_hash['unexpected_field'] = 'foo'
      domain_config = DomainConfig.new(config_hash)
      expect { domain_config.validate }.to raise_error(Rx::ValidationError, /Hash had extra keys/)
    end

    it "validates the type of the fields attribute" do
      config_hash['fields'] = [1, 2]
      domain_config = DomainConfig.new(config_hash)
      expect { domain_config.validate }.to raise_error(Rx::ValidationError, /expected String got 1/)
    end

    it "requires a url" do
      config_hash.delete('url')
      domain_config = DomainConfig.new(config_hash)
      expect { domain_config.validate }.to raise_error(Rx::ValidationError, /expected Hash to have key: 'url'/)
    end
  end

  context "#url" do
    it "returns the url" do
      domain_config = DomainConfig.new(config_hash)
      expect(domain_config.url).to eq(domain_url)
    end

    it "returns <Unconfigured Domain> if no url is specified" do
      config_hash.delete('url')
      domain_config = DomainConfig.new(config_hash)
      expect(domain_config.url).to eq('<Unconfigured Domain>')
    end
  end

  context "#name" do
    it "returns the specified name" do
      domain_config = DomainConfig.new(config_hash)
      expect(domain_config.name).to eq(domain_name)
    end

    it "returns the url if no name is given" do
      config_hash.delete('name')
      domain_config = DomainConfig.new(config_hash)
      expect(domain_config.name).to eq(domain_url)
    end
  end

  context "#fields" do
    it "returns the fields in the config" do
      domain_config = DomainConfig.new(config_hash)
      expect(domain_config.fields).to eq(custom_fields)
    end

    it "returns an empty array if no custom fields are specified" do
      config_hash.delete('fields')
      domain_config = DomainConfig.new(config_hash)
      expect(domain_config.fields).to eq([])
    end
  end

  context "#boards" do
    it "is optional" do
      config_hash.delete('boards')
      domain_config = DomainConfig.new(config_hash)
      domain_config.validate
    end

    it "returns the board configs" do
      domain_config = DomainConfig.new(config_hash)
      expect(domain_config.boards).to eq([
        DomainConfig::BoardDetails.new(board_jira_id, board_config_url)
      ])
    end
  end
end