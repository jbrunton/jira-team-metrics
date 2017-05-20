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

    def boards_store
      domain_name = config.get('defaults.domain')
      Store::Boards.instance(domain_name)
    end
  end
end
