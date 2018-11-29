module JiraTeamMetrics::ProjectsHelper
  def projects_path_singular(domain = nil)
    projects_name_singular(domain).underscore
  end

  def projects_path_plural(domain = nil)
    projects_name_plural(domain).underscore
  end

  def projects_name_singular(domain = nil)
    (domain || JiraTeamMetrics::Domain.get_active_instance).config.project_type.issue_type
  end

  def projects_name_plural(domain = nil)
    (domain || JiraTeamMetrics::Domain.get_active_instance).config.project_type.issue_type.pluralize
  end
end