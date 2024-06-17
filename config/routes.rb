Rails.application.routes.draw do
  resources :games, except: %i[update edit] do
    post "leave", to: "games#leave"
    get "join", to: "games#join"
    resources :rounds, only: %i[show create update] do
      resources :jokes, only: %i[index show create update]
    end
    resources :messages, only: %i[create]
  end
  
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  root "games#index"
end
