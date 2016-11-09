Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }

  scope '(:locale)', locale: /fr/ do
    root to: 'wunderlist#landing'

    require "sidekiq/web"
    authenticate :user, lambda { |u| u.admin } do
      mount Sidekiq::Web => '/sidekiq'
    end

    # WUNDERLIST INTEGRATION
    # Landing page for Wunderlist Users
    get '/wunderlist', to: 'wunderlist#landing'
    # Wunderlist webhook api
    match '/wunderlist' => 'wunderlist#webhook', via: :post, defaults: { formats: :json }

  end
end
