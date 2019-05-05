module JiraTeamMetrics::ChartsHelper
  def date_as_string(date)
    if date.class == DateTime
      "Date(#{date.year}, #{date.month - 1}, #{date.day}, #{date.hour}, #{date.min})"
    elsif date.class == Date
      "Date(#{date.year}, #{date.month - 1}, #{date.day})"
    else
      date
    end
  end
end