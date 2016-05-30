Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  resources :movies, only: [:show, :index]

  resources :users, only: [:index] do
    resources :friendships, only: [:show, :index]
  end
  get '/users/:user_id/watchlist' => 'interests#index', as: 'watchlist'

  resources :interests, only: [:create, :update, :destroy]
  root to: 'pages#home'

  mount Facebook::Messenger::Server, at: 'bot'

  require "sidekiq/web"
  authenticate :user, lambda { |u| u } do
    mount Sidekiq::Web => '/sidekiq'
  end
end
