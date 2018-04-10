class ReportOptions
  attr_reader :from_date
  attr_reader :to_date
  attr_reader :report_type

  def initialize(from_date, to_date, report_type)
    raise "Invalid report_type: #{report_type}" unless [:raw, :trained].include?(report_type)

    @from_date = from_date
    @to_date = to_date
    @report_type = report_type
  end

  def self.for(increment_report, report_type)
    # figure out start, end dates
  end
end