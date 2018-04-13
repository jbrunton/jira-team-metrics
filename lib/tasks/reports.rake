namespace :reports do

  desc "build report"
  task :build, [:board, :report_key] => :environment do |_, args|
    begin
      board = Board.find_by(jira_id: Integer(args.board))
      raise "Unable to find board" if board.nil?
    rescue
      board = Board.search(args.board)
    end
    report = DeliveryReportBuilder.for(board, args.report_key)
    puts "Building report #{args.report_key} for board #{board.name}"
    report.build
  end

  desc "build report fragment"
  task :build_fragment, [:board, :report_key, :fragment_key] => :environment do |_, args|
    begin
      board = Board.find_by(jira_id: Integer(args.board))
      raise "Unable to find board" if board.nil?
    rescue
      board = Board.search(args.board)
    end
    report = DeliveryReportBuilder.for(board, args.report_key)
    puts "Building report fragment #{args.report_key}:#{args.fragment_key} for board #{board.name}"
    report.build_fragment(args.fragment_key)
  end
end