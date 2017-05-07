require './stores/config'
require './stores/domains_store'
require './models/jira/client_builder'

class JiraTask < Thor
  include Thor::Actions
  
  no_commands do
    def config
      Store::Config.instance
    end

    def client
      @client ||= Jira::ClientBuilder.new
        .domains_store(domains_store)
        .config(config)
        .prompt
        .build
    end

    def domains_store
      DomainsStore.instance
    end
  end
end
