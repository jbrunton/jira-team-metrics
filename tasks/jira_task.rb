class JiraTask < Thor
  include Thor::Actions
  
  no_commands do
    def config
      Store::Config.instance
    end

    def client
      @client ||= JiraClientBuilder.new
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
