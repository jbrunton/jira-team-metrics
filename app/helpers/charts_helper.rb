module ChartsHelper
  def date_as_string(date)
    "Date(#{date.year}, #{date.month - 1}, #{date.day})"
  end
end