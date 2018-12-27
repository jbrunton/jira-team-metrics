crumb :root do
  domain = JiraTeamMetrics::Domain.get_active_instance
  link domain.config.name, domain_path
end

crumb :metadata do
  link 'Metadata', domain_metadata_path
end

crumb :sync_history do
  link 'Sync History', domain_sync_history_path
end

crumb :board do |board|
  link board.name, board
end

crumb :issue do |issue|
  link issue.key, issue
  parent :board, issue.board
end

crumb :report do |board, report_key, report_name|
  link "#{report_name} Report", "#{reports_path(board)}/#{report_key}"
  parent :board, board
end

crumb :epics do |board|
  link 'Epic Reports', epics_report_path(board)
  parent :board, board
end

crumb :epic do |epic|
  link epic.key, epic_report_path(epic)
  parent :epics, epic.board
end

crumb :projects do |board|
  link "#{projects_name_singular} Reports", projects_report_path(board)
  parent :board, board
end

crumb :project do |project|
  link project.key, project_report_path(project)
  parent :projects, project.board
end

crumb :project_scope_report do |project, team|
  link "#{team} Scope", project_scope_report_path(project, team)
  parent :project, project
end

crumb :project_throughput_report do |project, team|
  link "#{team} Throughput", project_throughput_report_path(project, team)
  parent :project, project
end

# If you want to split your breadcrumbs configuration over multiple files, you
# can create a folder named `config/breadcrumbs` and put your configuration
# files there. All *.rb files (e.g. `frontend.rb` or `products.rb`) in that
# folder are loaded and reloaded automatically when you change them, just like
# this file (`config/breadcrumbs.rb`).