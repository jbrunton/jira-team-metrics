require 'byebug'
require 'yaml/store'
require './tasks/jira_task'
require 'ruby-progressbar'

class Board < JiraTask
  def initialize(*args)
    super
    @store = Store::Boards.instance
  end

  desc "sync ID", "sync board"
  method_option :status, :aliases => "-s", :desc => "status"
  def sync(id)
    id = id.to_i
    status = options[:status]
    if status
        last_updated = @store.board_last_updated(id) || "Never"
        puts "Last updated: #{last_updated}"
    else
      board = @store.boards[id]
      progressbar = ProgressBar.create
      progressbar.progress = 0
      start_time = Time.now
      issues = client.search_issues(query: board['query']) do |progress|
        progressbar.progress = progress
      end
      end_time = Time.now
      puts "Elapsed time: #{(end_time - start_time).to_i}s"
      #client = ClientBuilder.new.prompt.build
      #rapid_view = client.RapidView.find(id)
      # rapid_views = client.RapidView.all.map do |rapid_view|
      #   [rapid_view.id, rapid_view.name]
      # end.to_h
      @store.update_board(id, issues.map{|issue| {key: issue.key, summary: issue.summary}})
      puts "Synced board"
    end
  end
end
