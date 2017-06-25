Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  get '/domains', to: 'domains#index'
  get '/domains/:domain_name', to: 'domains#show'

  get '/domains/:domain_name/boards/:board_id', to: 'boards#show'

  get '/reports/:domain_name/boards/:board_id/issues_by_type', to: 'reports#issues_by_type'

  get '/api/:domain_name/boards/:board_id/count_summary.json', to: 'api#count_summary'
end
