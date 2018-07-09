class JiraTeamMetrics::DateRange
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

  def to_a(interval_step = 'Daily')
    dates = []
    next_date = get_start_date(interval_step)
    byebug if next_date.nil?
    while next_date < end_date
      dates << next_date
      next_date = get_next_date(next_date, interval_step)
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

    overlap_start_date = [start_date, other.start_date].max
    overlap_end_date = [end_date, other.end_date].compact.min
    if overlap_end_date < overlap_start_date
      JiraTeamMetrics::DateRange.new(overlap_start_date, overlap_start_date)
    else
      JiraTeamMetrics::DateRange.new(overlap_start_date, overlap_end_date)
    end
  end

  def contains?(time)
    start_date <= time && time < end_date
  end

  def duration
    (end_date - start_date).to_f.abs
  end

  def to_query
    start_date_fm = start_date.strftime('%Y-%m-%d')
    end_date_fm = end_date.strftime('%Y-%m-%d')
    "from_date=#{start_date_fm}&to_date=#{end_date_fm}"
  end

private
  def get_start_date(interval_step)
    case interval_step
      when 'Daily'
        start_date
      when 'Weekly'
        start_date.beginning_of_week
      when 'Monthly'
        start_date.beginning_of_month
    end
  end

  def get_next_date(date, interval_step)
    case interval_step
      when 'Daily'
        date + 1
      when 'Weekly'
        date.next_week
      when 'Monthly'
        date.next_month
    end
  end
end
