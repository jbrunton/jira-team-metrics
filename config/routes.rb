JiraTeamMetrics::Engine.routes.draw do
  mount JasmineRails::Engine => '/specs' if defined?(JasmineRails)
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root 'home#index'

  get '/domain', to: 'domains#show'
  post '/domain/sync', to: 'domains#sync'
  post '/domain', to: 'domains#update'
  get'/domain/metadata', to: 'domains#metadata'

  get '/domain/boards/search', to: 'boards#search'
  get '/domain/boards/:board_id', to: 'boards#show'
  post '/domain/boards/:board_id/sync', to: 'boards#sync'
  post '/domain/boards/:board_id', to: 'boards#update'

  get '/domain/boards/:board_id/issues/:issue_key', to: 'issues#show'
  put '/domain/boards/:board_id/issues/:issue_key/flag_outlier', to: 'issues#flag_outlier'

  get '/reports/boards/:board_id/timesheets', to: 'reports#timesheets'
  get '/reports/boards/:board_id/deliveries', to: 'reports#deliveries'
  get '/reports/boards/:board_id/deliveries/:issue_key', to: 'reports#delivery'
  get '/reports/boards/:board_id/deliveries/:issue_key/scope/:team', to: 'reports#delivery_scope'
  get '/reports/boards/:board_id/scatterplot', to: 'reports#scatterplot'
  get '/reports/boards/:board_id/aging_wip', to: 'reports#aging_wip'

  get '/api/boards/:board_id/scatterplot.json', to: 'api#scatterplot'
  get '/api/boards/:board_id/aging_wip.json', to: 'api#aging_wip'

  get '/components/boards/:board_id/timesheets', to: 'components#timesheets'
end
