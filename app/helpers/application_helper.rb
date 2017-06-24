module ApplicationHelper
  def domains_path
    '/domains'
  end

  def domain_path(domain)
    "#{domains_path}/#{domain['name']}"
  end

  def board_path(domain, board)
    "#{domain_path(domain)}/boards/#{board.id}"
  end

  def board_issues_path(domain, board)
    "#{board_path(domain, board)}/issues"
  end

  def board_component_summary_path(domain, board)
    "#{board_path(domain, board)}/components/summary"
  end

  def board_control_chart_path(domain, board)
    "#{board_path(domain, board)}/control_chart"
  end

  def issue_path(issue)
    "#{board_issues_path(@domain, @board)}/#{issue.key}"
  end

  def path_for(object)
    if object.kind_of?(Issue)
      issue_path(object)
    end
  end

  # TODO: move this
  def render_table_options(object)
    path = path_for(object)
    "<a href='#{path}'>Details</a>"
  end

  # TODO: move this
  def date_as_string(date)
    "Date(#{date.year}, #{date.month - 1}, #{date.day})"
  end
end