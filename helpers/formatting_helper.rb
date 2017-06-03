module FormattingHelpers
  def pretty_print_date(date, show_tz = true)
    date.nil? ? '-' : date.strftime('%d %b %Y' + (show_tz ? ' %z' : ''))
  end

  def pretty_print_date_range(range, show_tz = false)
    "#{pretty_print_date(range.begin, show_tz)} - #{pretty_print_date(range.end, show_tz)}"
  end

  def pretty_print_time(time)
    time.nil? ? '-' : time.strftime('%d %b %Y %H:%M %z')
  end

  def pretty_print_number(number)
    number.nil? ? '-' : '%.2f' % number
  end
end