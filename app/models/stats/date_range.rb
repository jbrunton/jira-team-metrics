class DateRange
  attr_reader :start_date
  attr_reader :end_date

  def initialize(start_date, end_date)
    @start_date = start_date
    @end_date = end_date
  end

  def ==(other)
    self.class == other.class &&
      start_date == other.start_date &&
      end_date == other.end_date
  end
  alias :eql? :==

  def to_a
    dates = []
    next_date = dates.last || start_date
    while next_date < end_date
      dates << next_date
      next_date = next_date + 1.day
    end
    dates
  end

  def overlaps?(other)
    return false if start_date.nil? || other.start_date.nil?
    if end_date.nil?
      return other.end_date.nil? || start_date < other.end_date
    end
    if other.end_date.nil?
      return end_date.nil? || other.start_date < end_date
    end
    !(start_date > other.end_date || end_date < other.start_date)
  end

  def overlap_with(other)
    return nil if start_date.nil? || other.start_date.nil?
    return DateRange.new(
      [start_date, other.start_date].max,
      [end_date, other.end_date].compact.min
    )
  end

  def duration
    ((end_date - start_date) / 1.day).to_f
  end
end
