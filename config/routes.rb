Rails.application.routes.draw do
  mount MissionControl::Jobs::Engine, at: "/jobs"
  resource :session
  resources :passwords, param: :token
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      resources :auth, only: [ :create ] do
        collection do
          post :refresh
        end
      end
      resources :users do
        get :me, on: :collection
      end
    end
  end
end
