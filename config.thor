require 'jira-ruby'
require 'byebug'
require 'yaml/store'
require './jira_api/client_builder'

class Config < Thor
  desc "set PARAM VALUE", "set the config param to the given value"
  def set(param, value)
    config_store.transaction do
      config_store[param] = value
    end
    puts "Updated #{param} = #{value}"
  end

  desc "get PARAM", "read the value for the config param"
  def get(param)
    config_store.transaction do
      puts "#{param} = #{config_store[param]}"
    end
  end

  desc "clear PARAM", "clear the value for the config param"
  def clear(param)
    config_store.transaction do
      config_store[param] = nil
      puts "Cleared #{param}"
    end
  end

private

  def config_store
    @store ||= YAML::Store.new('data/config.yml')
  end
end
