module FormattingHelpers
  def pretty_print_date(date)
    date.nil? ? '-' : date.strftime('%d %b %Y')
  end

  def pretty_print_number(number)
    number.nil? ? '-' : '%.2f' % number
  end
end