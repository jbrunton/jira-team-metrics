class ReportFragment < ApplicationRecord
  serialize :contents
  belongs_to :board

  def self.fetch(board, report_key, fragment_key)
    board.report_fragments.find_by(report_key: report_key, fragment_key: fragment_key)
  end

  def self.fetch_contents(board, report_key, fragment_key)
    fetch(board, report_key, fragment_key).contents
  end
end
