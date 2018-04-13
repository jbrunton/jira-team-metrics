class ReportFragment < ApplicationRecord
  serialize :contents
  belongs_to :board

  def self.fetch(board, report_key, fragment_key)
    report_fragment = board.report_fragments.find_by(report_key: report_key, fragment_key: fragment_key)
    if report_fragment.nil?
      report_fragment = board.report_fragments.build(report_key: report_key, fragment_key: fragment_key)
      report_fragment.contents = yield
      report_fragment.save
    end
    report_fragment
  end
end
