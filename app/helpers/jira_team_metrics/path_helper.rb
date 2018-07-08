module JiraTeamMetrics::PathHelper
  include JiraTeamMetrics::ProjectsHelper

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

  def projects_report_path(board)
    "#{reports_path(board)}/#{projects_path_plural}"
  end

  def project_report_path(board, issue)
    "#{projects_report_path(board)}/#{issue.key}"
  end

  def project_scope_report_path(board, issue, team)
    "#{project_report_path(board, issue)}/scope/#{team}"
  end

  def project_throughput_report_path(board, issue, team)
    "#{project_report_path(board, issue)}/throughput/#{team}"
  end

  def timesheets_report_path(board, date_range = nil)
    url = "#{reports_path(board)}/timesheets"
    unless date_range.nil?
      url += "?#{date_range.to_query}"
    end
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