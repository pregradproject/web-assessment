namespace :api do
  namespace :v1 do
    resource :users, only: %i[show update] do
      member do
        get :profile, to: 'users#profile'
        post :login, to: 'users#login'
        post :register, to: 'users#register'
        post :google_login, to: 'users#google_login'
        post :password_reset, to: 'users#password_reset'
        post :password_reset_confirm, to: 'users#password_reset_confirm'
        patch :password_change, to: 'users#password_change'
      end

      resources :vark_tests, only: %i[index show create] do
        member do
          post :submit_answers, to: 'vark_tests#submit_answers'
          get :results, to: 'vark_tests#results'
        end

        collection do
          get :active_question_set, to: 'vark_tests#active_question_set'
        end

        resource :orders, only: %i[show create] do
          member do
            post :payment_token, to: 'orders#payment_token'
            post :generate_certificate, to: 'orders#generate_certificate'
            get :download_certificate, to: 'orders#download_certificate'
          end
        end
      end
    end

    # Midtrans webhook endpoint (no authentication needed)
    post 'payments/webhook', to: 'orders#webhook'
  end
end
