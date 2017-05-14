require 'byebug'
require 'yaml/store'
require './stores/config'

class Config < Thor
  def initialize(*args)
    super
    @config = Store::Config.instance
  end

  desc "set PARAM VALUE", "set the config param to the given value"
  def set(param, value)
    @config.set(param, value)
    puts "Updated #{param} = #{value}"
  end

  desc "get PARAM", "read the value for the config param"
  def get(param)
    value = @config.get(param)
    puts "#{param} = #{value}"
  end

  desc "clear PARAM", "clear the value for the config param"
  def clear(param)
    @config.set(param, nil)
    puts "Cleared #{param}"
  end

  desc "quickstart", "configure default options"
  def quickstart
    domain = ask('What JIRA domain do you want to query?')
    domain_name = ask('What name would you like to give this domain?')
    username = ask('What is your JIRA username?')
    @config.set 'defaults.domain', domain_name
    @config.set "defaults.domains.#{domain_name}.username", username
    Domains.new.invoke(:add, [domain_name, domain])
    Boards.new.invoke(:sync) if yes?('Would you like to sync the boards for that domain?')
    if yes?('Would you like to set a default board ID?')
      Boards.new.invoke(:list)
      @config.set "defaults.domains.#{domain_name}.board_id", ask('Which board ID do you want to query by default?')
    end
  end

private

  def config_store
    @store ||= YAML::Store.new('data/config.yml')
  end
end
