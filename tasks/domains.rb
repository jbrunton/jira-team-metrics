require './tasks/jira_task'
require './stores/domains_store'

class Domains < JiraTask
  def initialize(*args)
    super
    @store = DomainsStore.instance
  end

  desc "add NAME URL", "add a JIRA domain"
  def add(name, url)
    @store.add({
      'name' => name,
      'url' => url
    })
  end

  desc "remove NAME", "remove a domain"
  def remove(name)
    @store.remove(name)
  end

  desc "list", "list JIRA domains"
  def list
    rows = @store.all.map{ |domain| [domain['name'], domain['url']] }
    print_table(rows)
  end
end