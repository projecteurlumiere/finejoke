Rails.application.routes.draw do
  resources :games, except: %i[update edit] do
    get "join", to: "games#join"
    post "leave", to: "games#leave"
    post "kick", to: "games#kick"
    get "rules", to: "games#show_rules"
    get "over", to: "games#game_over"
    
    get "rounds/current", to: "rounds#show_current"
    resources :rounds, only: %i[show create update] do  
      resources :jokes, only: %i[index show create update]
    end

    resources :messages, only: %i[create]
  end

  resources :profiles, only: %i[show]
  resource :profile, only: %i[update], as: :self_profile
  devise_scope :user do
    get "profile/edit", to: "devise/registrations#edit", as: :edit_self_profile
  end

  post "award", to: "awards#gift"
  
  devise_scope :user do
    get "users/edit", to: redirect("profile/edit")
  end

  devise_for :users, controllers: {
    registrations: "users/registrations"
  }

  get "up" => "rails/health#show", as: :rails_health_check
  
  get "turbo_redirect_to", controller: "application"

  root "games#index"
end
