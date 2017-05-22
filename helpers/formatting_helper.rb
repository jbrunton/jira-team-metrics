module FormattingHelpers
  def pretty_print_date(date)
    date.nil? ? '-' : date.strftime('%d %b %Y %z')
  end

  def pretty_print_time(time)
    time.nil? ? '-' : time.strftime('%d %b %Y %H:%M %z')
  end

  def pretty_print_number(number)
    number.nil? ? '-' : '%.2f' % number
  end
end