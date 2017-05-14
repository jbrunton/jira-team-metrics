require 'byebug'
require 'yaml/store'
require './tasks/jira_task'
require 'ruby-progressbar'
require 'time'
require 'descriptive_statistics'

class Cache < Thor
  include Thor::Actions

  desc "clear", "clear cached board data"
  def clear
    remove_dir 'cache'
  end
end