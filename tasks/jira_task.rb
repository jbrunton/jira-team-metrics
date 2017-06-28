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
        raise 'Please provide a domain name or set a default domain'
      end

      Domain.find_by(name: domain_name)
    end

    def get_board(options)
      domain = get_domain(options)
      board_id = options[:board_id] || config.get("defaults.domains.#{domain.name}.board_id")

      if board_id.nil?
        raise 'Please provide a board id or set a default board for the domain'
      end

      domain.boards.find_by(jira_id: board_id)
    end
  end
end
