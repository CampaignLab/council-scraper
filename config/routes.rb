require 'sidekiq/web'

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  mount Sidekiq::Web, at: 'sidekiq'
  root 'home#index'
  get '/status', to: 'home#status'

  resources :councils, only: %i[index show]
  resources :decisions, only: %i[index show]
  resources :meetings, only: %i[index show]

  get '/search', to: 'search#index'
  post '/search', to: 'search#search'
end
