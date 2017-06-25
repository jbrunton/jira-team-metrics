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

    def get_domain(options)
      domain_name = options[:domain] || config.get('defaults.domain')

      if domain_name.empty?
        domain_name = ask('Which domain do you want to query?')
      end

      Domain.find_by(name: domain_name)
    end
  end
end
