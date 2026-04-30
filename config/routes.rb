Rails.application.routes.draw do
  root "lobbies#new"

  resources :games, only: [:create, :show], param: :code do
    member do
      post :start
      post :restart
    end
    resources :players, only: [:new, :create] do
      collection { get :join }
    end
    resource :controller, only: [:show], controller: "controllers"
    resources :claims, only: [:create, :update]
    resource :no_set, only: [:create, :update, :destroy]
  end

  mount ActionCable.server => "/cable"
  get "up" => "rails/health#show", :as => :rails_health_check
end
