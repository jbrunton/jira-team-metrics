require 'byebug'
require 'yaml/store'
require './stores/config'

class Config < JiraTask
  desc "set PARAM VALUE", "set the config param to the given value"
  def set(param, value)
    config.set(param, value)
    puts "Updated #{param} = #{value}"
  end

  desc "get PARAM", "read the value for the config param"
  def get(param)
    value = @config.get(param)
    puts "#{param} = #{value}"
  end

  desc "clear PARAM", "clear the value for the config param"
  def clear(param)
    config.set(param, nil)
    puts "Cleared #{param}"
  end

  desc "quickstart", "configure default options"
  def quickstart
    domain = ask('What JIRA domain do you want to query?')
    domain_name = ask('What name would you like to give this domain? (e.g. My Domain)')
    Domains.new.invoke(:add, [domain_name, domain])

    username = ask('What is your JIRA username?')
    config.set 'defaults.domain', domain_name
    config.set "defaults.domains.#{domain_name}.username", username

    if yes?('Would you like to sync the boards for that domain? (y/n)')
      Boards.new.invoke(:sync)
      Config.new.invoke(:default_board) if yes?('Would you like to set a default board? (y/n)')
    end
  end

  desc "default_board", "guide to help set the default board"
  def default_board
    domain_name = config.get('defaults.domain')

    query = ask('Enter a board ID or name (can be a partial match or regex)')
    results = boards_store.search(query)
      .map{ |board| [board.id, board.name] }

    if results.empty?
      say('Sorry, no results found.')
      Config.new.invoke(:default_board)
    elsif results.length > 1
      say('Found multiple matches:')
      print_table(results, indent: 2)
      Config.new.invoke(:default_board)
    else
      board_id, board_name = results.first
      config.set "defaults.domains.#{domain_name}.board_id", board_id
      say "Default board set to #{board_name}"
      Board.new.invoke(:sync) if yes?('Would you like to sync the default board? (y/n)')
    end
  end

  desc "defaults", "print config defaults"
  def defaults
    domain_name = config.get('defaults.domain')
    if domain_name
      domain_url = domains_store.find(domain_name)['url']
      say "Default domain: #{domain_name} (#{domain_url})"
    else
      say "No default domain set"
      exit
    end

    username = config.get("defaults.domains.#{domain_name}.username")
    if username
      say "  Username: #{username}"
    else
      say "  No default username set"
    end

    board_id = config.get("defaults.domains.#{domain_name}.board_id")
    if board_id
      say "  Board ID: #{board_id}"
    else
      say "  No board ID set"
    end
  end
end
