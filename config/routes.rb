Rails.application.routes.draw do
  get 'up' => 'rails/health#show', as: :rails_health_check
  
  namespace :api do
    namespace :v1 do
      post "production/enqueue", to: "production#enqueue"
      get  "production/next", to: "production#next"
      get  "production/in_progress", to: "production#in_progress"
      get  "production/:id", to: "production#show"
      post "production/:id/start", to: "production#start"
      post "production/:id/ready", to: "production#ready"
      post "production/:id/finalize", to: "production#finalize"
    end
  end
end
