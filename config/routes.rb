Rails.application.routes.draw do
  mount JasmineRails::Engine => '/specs' if defined?(JasmineRails)
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root 'home#index'

  get '/domain', to: 'domains#show'
  post '/domain/sync', to: 'domains#sync'
  post '/domain', to: 'domains#update'

  get '/domain/boards/search', to: 'boards#search'
  get '/domain/boards/:board_id', to: 'boards#show'
  post '/domain/boards/:board_id/sync', to: 'boards#sync'
  post '/domain/boards/:board_id', to: 'boards#update'

  get '/domain/boards/:board_id/issues/:issue_key', to: 'issues#show'
  put '/domain/boards/:board_id/issues/:issue_key/flag_outlier', to: 'issues#flag_outlier'

  get '/reports/boards/:board_id/issues_by_type', to: 'reports#issues_by_type'
  get '/reports/boards/:board_id/cycle_times_by_type', to: 'reports#cycle_times_by_type'
  get '/reports/boards/:board_id/control_chart', to: 'reports#control_chart'
  get '/reports/boards/:board_id/issues', to: 'reports#issues'
  get '/reports/boards/:board_id/compare', to: 'reports#compare'
  get '/reports/boards/:board_id/timesheets', to: 'reports#timesheets'
  get '/reports/boards/:board_id/delivery', to: 'reports#delivery'

  get '/api/boards/:board_id/count_summary.json', to: 'api#count_summary'
  get '/api/boards/:board_id/count_summary_by_month.json', to: 'api#count_summary_by_month'
  get '/api/boards/:board_id/effort_summary.json', to: 'api#effort_summary'
  get '/api/boards/:board_id/effort_summary_by_month.json', to: 'api#effort_summary_by_month'
  get '/api/boards/:board_id/created_summary_by_month.json', to: 'api#created_summary_by_month'
  get '/api/boards/:board_id/cycle_time_summary.json', to: 'api#cycle_time_summary'
  get '/api/boards/:board_id/cycle_time_summary_by_month.json', to: 'api#cycle_time_summary_by_month'
  get '/api/boards/:board_id/control_chart.json', to: 'api#control_chart'
  get '/api/boards/:board_id/compare.json', to: 'api#compare'

  get '/components/boards/:board_id/wip/:date', to: 'components#wip'
  get '/components/boards/:board_id/issues_list', to: 'components#issues_list'
  get '/components/boards/:board_id/timesheets', to: 'components#timesheets'
end
