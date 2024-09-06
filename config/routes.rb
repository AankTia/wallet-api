Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  namespace :api do
    namespace :v1 do
      resources :wallet, only: [] do
        collection do
          get 'balance'
        end
      end

      resources :transaction, only: [] do
        collection do
          post 'deposit'
          post 'withdraw'
          post 'transfer'
          get 'detail/:id', action: :detail, as: 'detail'
          get 'history'
        end
      end
    end
  end
end
