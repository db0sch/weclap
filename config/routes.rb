Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  scope '(:locale)', locale: /fr/ do
    resources :sort, only: [:index]
    resources :movies, only: [:show, :index]
    resources :users, only: [:index] do
      resources :friendships, only: [:show, :index]
    end
    resources :interests, only: [:create, :update, :destroy]

    get '/users/:user_id/watchlist' => 'interests#index', as: 'watchlist'
    get 'search' => 'search#index'
    get 'search/autocomplete', to: 'search#autocomplete'

    # No id for the profile route (user#show).
    # It is volontary, as for now, user can access is own profile only
    get '/profile', to: 'users#show', as: 'profile'


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
end
