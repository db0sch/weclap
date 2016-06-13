Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  resources :movies, only: [:show, :index]

  resources :users, only: [:index] do
    resources :friendships, only: [:show, :index]
  end
  get '/users/:user_id/watchlist' => 'interests#index', as: 'watchlist'
  get 'search' => 'search#index'

  resources :interests, only: [:create, :update, :destroy]

  authenticated :user do
    root 'interests#index', as: :authenticated_root
  end
  root to: 'pages#home'

  mount Facebook::Messenger::Server, at: 'bot'

  require "sidekiq/web"
  authenticate :user, lambda { |u| u.admin } do
    mount Sidekiq::Web => '/sidekiq'
  end
end
