module JiraTeamMetrics::PathHelper
  def domain_path
    "#{root_path}domain"
  end

  def domain_metadata_path
    "#{domain_path}/metadata"
  end

  def board_path(board)
    "#{domain_path}/boards/#{board.jira_id}"
  end

  def reports_path(board)
    "#{root_path}reports/boards/#{board.jira_id}"
  end

  def deliveries_report_path(board)
    "#{reports_path(board)}/deliveries"
  end

  def delivery_report_path(board, issue)
    "#{deliveries_report_path(board)}/#{issue.key}"
  end

  def delivery_scope_report_path(board, issue, team)
    "#{delivery_report_path(board, issue)}/scope/#{team}"
  end

  def delivery_throughput_report_path(board, issue, team)
    "#{delivery_report_path(board, issue)}/throughput/#{team}"
  end

  def timesheets_report_path(board, date_range = nil)
    url = "#{reports_path(board)}/timesheets"
    url += "?" unless date_range.nil?
    url += "from_date=#{date_range.start_date.strftime('%Y-%m-%d')}&" unless date_range.nil?
    url += "to_date=#{date_range.end_date.strftime('%Y-%m-%d')}" unless date_range.nil?
    url
  end

  def board_components_path(board)
    "#{root_path}components/boards/#{board.jira_id}"
  end

  def board_api_path(board)
    "#{root_path}api/boards/#{board.jira_id}"
  end

  def issue_path(issue)
    "#{board_path(issue.board)}/issues/#{issue.key}"
  end

  def path_for(object)
    if object.kind_of?(JiraTeamMetrics::Issue)
      issue_path(object)
    end
  end
end