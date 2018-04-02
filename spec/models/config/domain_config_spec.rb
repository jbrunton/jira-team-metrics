require 'rails_helper'

RSpec.describe DomainConfig do
  let(:custom_fields) { ['My Field'] }
  let(:link_types) { ['blocks'] }

  let(:config_hash) do
    {
      'fields' => custom_fields,
      'link_types' => link_types
    }
  end

  it "initializes #config_hash" do
    domain_config = DomainConfig.new(config_hash)
    expect(domain_config.config_hash).to eq(config_hash)
  end

  context "#validate" do
    it "validates the config" do
      config_hash['unexpected_field'] = 'foo'
      domain_config = DomainConfig.new(config_hash)
      expect { domain_config.validate }.to raise_error(Rx::ValidationError, /Hash had extra keys/)
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

  context "#link_types" do
    it "returns the link types in the config" do
      domain_config = DomainConfig.new(config_hash)
      expect(domain_config.link_types).to eq(link_types)
    end

    it "returns an empty array if no custom fields are specified" do
      config_hash.delete('link_types')
      domain_config = DomainConfig.new(config_hash)
      expect(domain_config.link_types).to eq([])
    end
  end
end