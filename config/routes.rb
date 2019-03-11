include JiraTeamMetrics::ProjectsHelper

JiraTeamMetrics::Engine.routes.draw do
  mount JasmineRails::Engine => '/specs' if defined?(JasmineRails)
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root 'home#index'

  get '/domain', to: 'domains#show'
  post '/domain/sync', to: 'domains#sync'
  post '/domain', to: 'domains#update'
  get'/domain/metadata', to: 'domains#metadata'
  get'/domain/sync_history', to: 'domains#sync_history'

  get '/domain/boards/search', to: 'boards#search'
  get '/domain/boards/:board_id', to: 'boards#show'
  post '/domain/boards/:board_id/sync', to: 'boards#sync'
  post '/domain/boards/:board_id', to: 'boards#update'

  get '/domain/boards/:board_id/issues/search', to: 'issues#search'
  get '/domain/boards/:board_id/issues/:issue_key', to: 'issues#show'
  put '/domain/boards/:board_id/issues/:issue_key/flag_outlier', to: 'issues#flag_outlier'

  get '/reports/boards/:board_id/query', to: 'reports#query'

  get '/reports/boards/:board_id/timesheets', to: 'reports#timesheets'
  get '/reports/boards/:board_id/throughput', to: 'reports#throughput'

  get '/reports/boards/:board_id/epics', to: 'reports#epics'
  get '/reports/boards/:board_id/epics/:issue_key', to: 'reports#epic'

  unless ActiveRecord::Base.connection.migration_context.needs_migration?
    unless JiraTeamMetrics::Domain.get_active_instance.config.projects.issue_type.blank?
      get "/reports/boards/:board_id/#{projects_path_plural}", to: 'reports#projects'
      get "/reports/boards/:board_id/#{projects_path_plural}/:issue_key", to: 'reports#project'
      get "/reports/boards/:board_id/#{projects_path_plural}/:issue_key/scope/:team", to: 'reports#project_scope'
      get "/reports/boards/:board_id/#{projects_path_plural}/:issue_key/throughput/:team", to: 'reports#project_throughput'
    end
  end
  get '/reports/boards/:board_id/scatterplot', to: 'reports#scatterplot'
  get '/reports/boards/:board_id/aging_wip', to: 'reports#aging_wip'

  get '/api/boards/:board_id/time_period_options', to: 'api#time_period_options'
  get '/api/boards/:board_id/query', to: 'api#query'
  get '/api/boards/:board_id/scatterplot.json', to: 'api#scatterplot'
  get '/api/boards/:board_id/aging_wip.json', to: 'api#aging_wip'
  get '/api/boards/:board_id/throughput.json', to: 'api#throughput'
  get '/api/boards/:board_id/throughput/:team.json', to: 'api#throughput'
  get '/api/boards/:board_id/progress_cfd/:issue_key.json', to: 'api#progress_cfd'
  get '/api/boards/:board_id/progress_cfd/:issue_key/teams/:team.json', to: 'api#progress_cfd'

  get '/components/boards/:board_id/timesheets', to: 'components#timesheets'
  get '/components/boards/:board_id/throughput_drilldown', to: 'components#throughput_drilldown'
  get '/components/boards/:board_id/progress_summary/:issue_key', to: 'components#progress_summary'
  get '/components/boards/:board_id/progress_summary/:issue_key/teams/:team', to: 'components#progress_summary'

end
