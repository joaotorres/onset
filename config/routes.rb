Rails.application.routes.draw do
  root "lobbies#new"
  get "join" => "lobbies#join", :as => :join_by_code

  resources :games, only: [:create, :show], param: :code do
    member do
      post :start
      post :restart
      post :ready
    end
    resources :players, only: [:new, :create] do
      collection { get :join }
    end
    resource :controller, only: [:show], controller: "controllers"
    resources :claims, only: [:create, :update]
    resource :no_set, only: [:create, :update, :destroy]
    resource :end_game, only: [:create]
  end

  mount ActionCable.server => "/cable"
  get "up" => "rails/health#show", :as => :rails_health_check
end
