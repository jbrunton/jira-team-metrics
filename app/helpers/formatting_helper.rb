module FormattingHelper
  def pretty_print_date(date, opts = {show_tz: true, hide_year: false})
    opts ||= {}
    strfm = opts[:hide_year] ? '%d %b' : '%d %b %Y'
    strfm = ('%a ' + strfm) if opts[:show_day]
    strfm += ' %z' if opts[:show_tz]
    date.nil? ? '-' : date.strftime(strfm)
  end

  def pretty_print_date_range(range, opts = {show_tz: false})
    opts ||= {}
    "#{pretty_print_date(range.begin, opts)} - #{pretty_print_date(range.end, opts)}"
  end

  def pretty_print_time(time)
    time.nil? ? '-' : time.strftime('%d %b %Y %H:%M %z')
  end

  def pretty_print_number(number, opts = {})
    if number.nil?
      '-'
    elsif opts[:round]
      '%.0f' % number
    else
      '%.2f' % number
    end
  end
end