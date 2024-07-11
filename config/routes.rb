Rails.application.routes.draw do
  resources :games, except: %i[update edit] do
    post "join", to: "games#join"
    post "leave", to: "games#leave"
    post "kick", to: "games#kick"

    resources :rounds, only: %i[show create update] do
      resources :jokes, only: %i[index show create update]
    end
    resources :messages, only: %i[create]
  end

  resource :profile, only: %i[show edit update]
  resources :profiles, only: %i[show]
  
  devise_for :users
  get "up" => "rails/health#show", as: :rails_health_check
  
  get "turbo_redirect_to", controller: "application"

  root "games#index"
end
