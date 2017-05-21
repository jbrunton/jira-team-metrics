class DateRange
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
end
