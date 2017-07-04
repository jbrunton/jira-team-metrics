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

  get '/reports/:domain_name/boards/:board_id/issues_by_type', to: 'reports#issues_by_type'
  get '/reports/:domain_name/boards/:board_id/cycle_times_by_type', to: 'reports#cycle_times_by_type'
  get '/reports/:domain_name/boards/:board_id/control_chart', to: 'reports#control_chart'
  get '/reports/:domain_name/boards/:board_id/issues', to: 'reports#issues'

  get '/api/:domain_name/boards/:board_id/count_summary.json', to: 'api#count_summary'
  get '/api/:domain_name/boards/:board_id/cycle_time_summary.json', to: 'api#cycle_time_summary'
  get '/api/:domain_name/boards/:board_id/cycle_time_summary_by_month.json', to: 'api#cycle_time_summary_by_month'
  get '/api/:domain_name/boards/:board_id/control_chart.json', to: 'api#control_chart'

  get '/components/:domain_name/boards/:board_id/wip/:date', to: 'components#wip'
  get '/components/:domain_name/boards/:board_id/issues_list', to: 'components#issues_list'
end
