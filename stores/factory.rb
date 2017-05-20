require 'fileutils'

module Store
  class Factory
    def initialize
      @stores = {}
    end
    
    def create(name)
      filename = "cache/#{name}.yml"
      dirname = File.dirname(filename)
      FileUtils.mkdir_p(dirname) unless Dir.exist?(dirname)
      YAML::Store.new(filename)
    end

    def find_or_create(name)
      @stores[name] ||= create(name)
    end

    def self.instance
      @@instance ||= Factory.new
    end
  end
end
