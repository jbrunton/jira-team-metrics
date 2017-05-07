require './stores/config'
require './models/jira/client_builder'

class JiraTask < Thor
  include Thor::Actions
  
  no_commands do
    def config
      Store::Config.instance
    end

    def client
      @client ||= Jira::ClientBuilder.new.config(config).prompt.build
    end
  end
end
