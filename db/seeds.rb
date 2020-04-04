# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

require 'factory_bot_rails'
include FactoryBot::Syntax::Methods

srand(125)

FactoryBot.definition_file_paths = %w{spec/factories}
FactoryBot.find_definitions

def ensure_board(name)
  domain = JiraTeamMetrics::Domain.get_active_instance
  if domain.new_record?
    domain = create(:domain)
  end

  jira_id = name.parameterize
  board = domain.boards.find_by(jira_id: jira_id)

  if board.nil?
    board = build(:board, name: name, domain: domain, jira_id: jira_id)
  end

  yield(board) if block_given?

  board.save
end

def create_completed_issue(board)
  started_time = DateTime.now - (rand * 12 + 12).days
  completed_time = started_time + (rand * 12).days
  create(:issue, board: board, started_time: started_time, completed_time: completed_time)
end

ensure_board('Empty Board')

ensure_board('Single Issue Board') do |board|
  create_completed_issue(board) if board.issues.empty?
end

ensure_board('Five Issue Board') do |board|
  5.times { create_completed_issue(board) } if board.issues.empty?
end

ensure_board('Twenty Issue Board') do |board|
  20.times { create_completed_issue(board) } if board.issues.empty?
end
