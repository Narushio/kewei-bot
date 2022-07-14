Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  if defined?(Sidekiq) && defined?(Sidekiq::Cron)
    mount Sidekiq::Web => "/sidekiq"
  end
end
