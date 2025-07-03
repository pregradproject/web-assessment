Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # Allow all origins in development, specific domains in production
    if Rails.env.development?
      origins '*'
    else
      origins ENV.fetch('CORS_ORIGINS', 'https://cakravia-v0.vercel.app').split(',')
    end

    resource '/api/*',
      headers: :any,
      methods: [ :get, :post, :put, :patch, :delete, :options, :head ],
      expose: [ 'Authorization' ],
      credentials: false
  end
end
