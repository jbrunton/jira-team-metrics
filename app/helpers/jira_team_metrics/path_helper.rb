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

  def epics_report_path(board)
    "#{reports_path(board)}/epics"
  end

  def epic_report_path(epic)
    "#{reports_path(epic.board)}/epics/#{epic.key}"
  end

  def projects_report_path(board)
    "#{reports_path(board)}/#{projects_path_plural}"
  end

  def project_report_path(project)
    "#{projects_report_path(project.board)}/#{project.key}"
  end

  def project_scope_report_path(project, team)
    "#{project_report_path(project)}/scope/#{CGI::escape(team)}"
  end

  def project_throughput_report_path(project, team)
    "#{project_report_path(project)}/throughput/#{CGI::escape(team)}"
  end

  def throughput_drilldown_path(board)
    "#{board_components_path(board)}/throughput_drilldown"
  end

  def epic_progress_summary_path(epic)
    "#{board_components_path(epic.board)}/progress_summary/#{epic.key}"
  end

  def epic_cfd_path(epic)
    "#{board_api_path(epic.board)}/progress_cfd/#{epic.key}.json"
  end

  def project_progress_summary_path(project, team)
    "#{board_components_path(project.board)}/progress_summary/#{project.key}/teams/#{CGI::escape(team)}"
  end

  def project_cfd_path(project, team)
    "#{board_api_path(project.board)}/progress_cfd/#{project.key}/teams/#{CGI::escape(team)}.json"
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

  def progress_report_for(issue)
    case issue.hierarchy_level
      when 'Epic'
        epic_report_path(issue)
      when 'Project'
        project_report_path(issue)
      else
        raise "Invalid hierarchy_level: #{issue.hierarchy_level}"
    end
  end

  def jira_board_url(board)
    "#{board.domain.config.url}/secure/RapidBoard.jspa?rapidView=#{board.jira_id}"
  end

  def jira_board_issues_url(board)
    "#{board.domain.config.url}/issues/?jql=#{board.query}"
  end
end