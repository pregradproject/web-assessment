namespace :api do
  namespace :v1 do
    resource :users, only: %i[show update] do
      member do
        get :profile, to: 'users#profile'
        post :login, to: 'users#login'
        post :register, to: 'users#register'
      end
    end
  end
end
