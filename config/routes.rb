Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }

  scope '(:locale)', locale: /fr/ do
    resources :interests, only: [ :index ]
    # resources :wunderlist, only: [ :index ]
    authenticated :user do
      root to: 'pages#howto', as: :authenticated_root
    end
    root to: 'pages#home'


    require "sidekiq/web"
    authenticate :user, lambda { |u| u.admin } do
      mount Sidekiq::Web => '/sidekiq'
    end

    # WUNDERLIST INTEGRATION
    # Wunderlist webhook api
    match '/wunderlist' => 'wunderlist#webhook', via: :post, defaults: { formats: :json }
    # should probably use something else for the api endpoint. Match is certainly not the best method.
  end
end
