namespace :api do
  namespace :v1 do
    resource :users, only: %i[show update] do
      member do
        get :profile, to: 'users#profile'
        post :login, to: 'users#login'
        post :register, to: 'users#register'
      end

      resource :vark_tests, only: %i[show create] do
        member do
          # get :active_question_set, to: 'vark_tests#active_question_set'
          # post :submit_answers, to: 'vark_tests#submit_answers'
        end
      end
    end
  end
end
