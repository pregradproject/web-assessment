namespace :api do
  namespace :v1 do
    # Configuration endpoint (public)
    resource :config, only: [ :show ]

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

      resources :ai_knowledge_tests, only: %i[index show create] do
        member do
          post :submit_answers, to: 'ai_knowledge_tests#submit_answers'
          get :results, to: 'ai_knowledge_tests#results'
        end

        collection do
          get :active_question_set, to: 'ai_knowledge_tests#active_question_set'
        end

        resource :orders, only: %i[show create] do
          member do
            post :payment_token, to: 'orders#payment_token'
            post :generate_certificate, to: 'orders#generate_certificate'
            get :download_certificate, to: 'orders#download_certificate'
          end
        end
      end

      resources :behavioral_learning_tests, only: %i[index show create] do
        member do
          post :submit_answers, to: 'behavioral_learning_tests#submit_answers'
          get :results, to: 'behavioral_learning_tests#results'
        end

        collection do
          get :active_question_set, to: 'behavioral_learning_tests#active_question_set'
        end

        resource :orders, only: %i[show create] do
          member do
            post :payment_token, to: 'orders#payment_token'
            post :generate_certificate, to: 'orders#generate_certificate'
            get :download_certificate, to: 'orders#download_certificate'
          end
        end
      end

      resources :comprehensive_assessment_tests, only: %i[index show create] do
        member do
          post :submit_answers, to: 'comprehensive_assessment_tests#submit_answers'
          get :results, to: 'comprehensive_assessment_tests#results'
        end

        collection do
          get :active_question_set, to: 'comprehensive_assessment_tests#active_question_set'
        end

        resource :orders, only: %i[show create] do
          member do
            post :payment_token, to: 'orders#payment_token'
            post :generate_certificate, to: 'orders#generate_certificate'
            get :download_certificate, to: 'orders#download_certificate'
          end
        end
      end

      resources :tpa_tests, only: %i[index show create] do
        member do
          post :submit_answers, to: 'tpa_tests#submit_answers'
          get :results, to: 'tpa_tests#results'
        end

        collection do
          get :active_question_set, to: 'tpa_tests#active_question_set'
          post :order, to: 'tpa_tests#create_order'
        end

        resource :orders, only: %i[show create] do
          member do
            post :payment_token, to: 'orders#payment_token'
            post :generate_certificate, to: 'orders#generate_certificate'
            get :download_certificate, to: 'orders#download_certificate'
          end
        end
      end

      # Standalone order endpoints for TPA flow
      resources :orders, only: [ :show ] do
        member do
          post :payment_token, to: 'orders#standalone_payment_token'
        end
      end

      # Coupon validation endpoint
      resource :coupons, only: [] do
        collection do
          post :validate, to: 'coupons#validate'
        end
      end
    end

    # Midtrans webhook endpoint (no authentication needed, outside users namespace)
    post 'payments/webhook', to: 'orders#webhook'
  end
end
