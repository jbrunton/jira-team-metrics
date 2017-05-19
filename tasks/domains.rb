class Domains < JiraTask
  desc "add NAME URL", "add a JIRA domain"
  def add(name, url)
    client = JiraClientBuilder.new.config(config).url(url).prompt.build
    statuses = client.get_statuses
    domains_store.add({
      'name' => name,
      'url' => url,
      'statuses' => statuses
    })
  end

  desc "remove NAME", "remove a domain"
  def remove(name)
    domains_store.remove(name)
  end

  desc "list", "list JIRA domains"
  def list
    rows = domains_store.all.map{ |domain| [domain['name'], domain['url']] }
    print_table(rows)
  end
end