Rails.application.routes.draw do
  get 'up' => 'rails/health#show', as: :rails_health_check

  draw(:admin)
  draw(:jobs)
  draw(:api)

  match '*path' => 'api#no_routes', via: :all, constraints: lambda { |req|
    req.path.exclude? 'rails/active_storage'
  }
end
