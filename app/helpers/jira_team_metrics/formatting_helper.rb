module JiraTeamMetrics::FormattingHelper
  def format_mql_date(date)
    date.strftime('%Y-%m-%d')
  end

  def pretty_print_date(date, opts = {show_tz: true, month_only: false, hide_year: false})
    strfm = date_format_for(opts, date)
    date.nil? ? '-' : date.strftime(strfm)
  end

  def pretty_print_time(time)
    time.nil? ? '-' : time.strftime('%d %b %Y %H:%M %Z')
  end

  def pretty_print_number(number, opts = {})
    if number.nil?
      '-'
    else
      fm = number_format_for(opts)
      val = fm % number
      add_units(val, opts)
    end
  end

  def pretty_print_date_range(date_range)
    start_date_fm = pretty_print_date(date_range.start_date, show_tz: false, hide_year: true)
    end_date_fm = pretty_print_date(date_range.end_date, show_tz: false, hide_year: true)
    "#{start_date_fm} - #{end_date_fm}"
  end

private
  def date_format_for(opts, date)
    opts ||= {}
    strfm = ''
    strfm += '%d' unless opts[:month_only]
    strfm += ' %b'
    strfm += ' %Y' unless hide_year?(opts, date)
    strfm = ('%a ' + strfm) if opts[:show_day]
    strfm += ' %Z' if opts[:show_tz]
    strfm.strip
  end

  def number_format_for(opts)
    opts[:round] ? '%.0f' : '%.2f'
  end

  def add_units(val, opts)
    if opts[:percentage]
      "#{val} %"
    else
      val
    end
  end

  def hide_year?(opts, date)
    opts[:hide_year] && date.year == DateTime.now.year unless date.nil?
  end
end