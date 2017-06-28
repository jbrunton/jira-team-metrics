Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  get '/domains', to: 'domains#index'
  get '/domains/:domain_name', to: 'domains#show'
  post '/domains', to: 'domains#create'
  get '/domains/:domain_name/sync', to: 'domains#sync'

  get '/domains/:domain_name/boards/:board_id', to: 'boards#show'

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
