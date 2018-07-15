module JiraTeamMetrics::ProjectsHelper
  def projects_path_singular
    projects_name_singular.underscore
  end

  def projects_path_plural
    projects_name_plural.underscore
  end

  def projects_name_singular
    JiraTeamMetrics::Domain.get_instance.config.project_type.issue_type
  end

  def projects_name_plural
    JiraTeamMetrics::Domain.get_instance.config.project_type.issue_type.pluralize
  end
end