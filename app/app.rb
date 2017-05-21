require 'sinatra'
require 'sinatra/content_for'
require 'yaml/store'
require 'byebug'
require 'chartkick'

require 'require_all'
['models', 'stores'].each { |dir| require_all dir }

helpers do
  def home_path
    '/'
  end

  def domain_path(domain)
    "/#{domain['name']}"
  end

  def board_path(domain, board)
    "#{domain_path(domain)}/boards/#{board.id}"
  end

  def board_issues_path(domain, board)
    "#{board_path(domain, board)}/issues"
  end

  def issue_path(issue)
    "#{board_issues_path(@domain, @board)}/#{issue.key}"
  end

  def path_for(object)
    if object.kind_of?(Issue)
      issue_path(object)
    end
  end

  def render_table_options(object)
    path = path_for(object)
    "<a href='#{path}'>Details</a>"
  end

  def date_as_string(date)
    "Date(#{date.year}, #{date.month}, #{date.day})"
  end
end

before '/:domain*' do
  domain_name = params[:domain]
  @domain = DomainsStore.instance.find(domain_name)
end

before '/:domain/boards/:board_id*' do
  board = Store::Boards.instance(@domain['name']).get_board(params[:board_id].to_i)
  @board = BoardDecorator.new(board, nil, nil)
end

get '/' do
  @domains = DomainsStore.instance.all
  erb 'domains/index'.to_sym
end

get '/:domain' do
  @boards = Store::Boards.instance(@domain['name']).all.select do |board|
    !board.last_updated.nil?
  end
  erb 'domains/show'.to_sym
end

get '/:domain/boards/:board_id' do
  @chart_data = {
    cols: [{type: 'date', label: 'Completed'}, {type: 'number', label: 'Cycle Time'}, {type: 'string', role: 'tooltip'}],
    rows: @board.completed_issues.map do |issue|
      {c: [{v: date_as_string(issue.completed)}, {v: issue.cycle_time}, {v: issue.key}]}
    end
  }
  erb 'boards/show'.to_sym
end

get '/:domain/boards/:board_id/issues' do
  erb 'boards/issues'.to_sym
end

get '/:domain/boards/:board_id/issues/:issue_key' do
  @issue = @board.issues.find{ |i| i.key == params[:issue_key] }
  if params[:fragment]
    erb 'partials/issue'.to_sym, locals: {issue: @issue}, layout: false
  else
    erb 'issues/show'.to_sym
  end
end