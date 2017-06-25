Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  get '/domains', to: 'domains#index'
  get '/domains/:domain_name', to: 'domains#show'
end
