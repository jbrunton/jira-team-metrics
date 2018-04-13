namespace :reports do

  desc "build report"
  task :build, [:board_id, :report_key] => :environment do |_, args|
    board = Board.find_by(jira_id: args.board_id)
    byebug
    report = DeliveryReport.for(board, args.report_key)
    puts "Building report #{args.report_key} for board #{board.name}"
    report.build
  end
end