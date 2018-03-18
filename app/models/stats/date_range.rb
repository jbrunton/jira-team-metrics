class DateRange
  attr_reader :start_date
  attr_reader :end_date

  def initialize(start_date, end_date)
    @start_date = start_date
    @end_date = end_date
  end

  def to_a
    dates = []
    next_date = dates.last || @start_date
    while next_date < @end_date
      dates << next_date
      next_date = next_date + 1.day
    end
    dates
  end

  def overlaps?(other)
    return false if @start_date.nil?
    return false if @end_date.nil? || @end_date < other.start_date
    return false if other.end_date < @start_date
    true
  end
end
