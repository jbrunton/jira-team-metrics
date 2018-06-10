module JiraTeamMetrics::FormattingHelper
  def pretty_print_date(date, opts = {show_tz: true, hide_year: false})
    strfm = date_format_for(opts)
    date.nil? ? '-' : date.strftime(strfm)
  end

  def pretty_print_time(time)
    time.nil? ? '-' : time.strftime('%d %b %Y %H:%M %Z')
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

  def pretty_print_date_range(date_range)
    start_date_fm = pretty_print_date(date_range.start_date, show_tz: false, hide_year: true)
    end_date_fm = pretty_print_date(date_range.end_date, show_tz: false, hide_year: true)
    "#{start_date_fm} - #{end_date_fm}"
  end

private
  def date_format_for(opts)
    opts ||= {}
    strfm = '%d %b'
    strfm += ' %Y' unless opts[:hide_year]
    strfm = ('%a ' + strfm) if opts[:show_day]
    strfm += ' %Z' if opts[:show_tz]
    strfm
  end
end