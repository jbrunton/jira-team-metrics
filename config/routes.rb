Rails.application.routes.draw do
  mount JasmineRails::Engine => '/specs' if defined?(JasmineRails)
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root 'domains#index'

  get '/domains', to: 'domains#index'
  get '/domains/:domain_name', to: 'domains#show'
  post '/domains', to: 'domains#create'
  delete '/domains/:domain_name', to: 'domains#destroy'
  post '/domains/:domain_name/sync', to: 'domains#sync'
  post '/domains/:domain_name', to: 'domains#update'

  get '/domains/:domain_name/boards/search', to: 'boards#search'
  get '/domains/:domain_name/boards/:board_id', to: 'boards#show'
  post '/domains/:domain_name/boards/:board_id/sync', to: 'boards#sync'
  post '/domains/:domain_name/boards/:board_id', to: 'boards#update'

  get '/domains/:domain_name/boards/:board_id/issues/:issue_key', to: 'issues#show'
  put '/domains/:domain_name/boards/:board_id/issues/:issue_key/flag_outlier', to: 'issues#flag_outlier'

  get '/reports/:domain_name/boards/:board_id/issues_by_type', to: 'reports#issues_by_type'
  get '/reports/:domain_name/boards/:board_id/cycle_times_by_type', to: 'reports#cycle_times_by_type'
  get '/reports/:domain_name/boards/:board_id/control_chart', to: 'reports#control_chart'
  get '/reports/:domain_name/boards/:board_id/issues', to: 'reports#issues'
  get '/reports/:domain_name/boards/:board_id/compare', to: 'reports#compare'
  get '/reports/:domain_name/boards/:board_id/timesheets', to: 'reports#timesheets'

  get '/api/:domain_name/boards/:board_id/count_summary.json', to: 'api#count_summary'
  get '/api/:domain_name/boards/:board_id/count_summary_by_month.json', to: 'api#count_summary_by_month'
  get '/api/:domain_name/boards/:board_id/effort_summary.json', to: 'api#effort_summary'
  get '/api/:domain_name/boards/:board_id/effort_summary_by_month.json', to: 'api#effort_summary_by_month'
  get '/api/:domain_name/boards/:board_id/created_summary_by_month.json', to: 'api#created_summary_by_month'
  get '/api/:domain_name/boards/:board_id/cycle_time_summary.json', to: 'api#cycle_time_summary'
  get '/api/:domain_name/boards/:board_id/cycle_time_summary_by_month.json', to: 'api#cycle_time_summary_by_month'
  get '/api/:domain_name/boards/:board_id/control_chart.json', to: 'api#control_chart'
  get '/api/:domain_name/boards/:board_id/compare.json', to: 'api#compare'

  get '/components/:domain_name/boards/:board_id/wip/:date', to: 'components#wip'
  get '/components/:domain_name/boards/:board_id/issues_list', to: 'components#issues_list'
  get '/components/:domain_name/boards/:board_id/timesheets', to: 'components#timesheets'
end
