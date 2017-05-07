require 'byebug'
require 'yaml/store'
require './store/config'

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

private

  def config_store
    @store ||= YAML::Store.new('data/config.yml')
  end
end
