Rails.application.routes.draw do
  resources :games, except: %i[new edit update] do
    post "join", to: "games#join"
    post "leave", to: "games#leave"
    post "kick", to: "games#kick"
    get "rules", to: "games#show_rules"
    get "over", to: "games#game_over"
    
    get "rounds/current", to: "rounds#show_current"
    post "rounds/:id/skip_results", to: "rounds#skip_results", as: :round_skip_results
    
    resources :rounds, only: %i[show create update] do
      resources :jokes, only: %i[index show create]
      patch "/jokes/:id/vote", to: "jokes#vote", as: :joke_vote
    end

    resources :messages, only: %i[create]
  end

  post "suggest_setup", to: "suggestions#suggest_setup", as: :suggest_setup
  post "suggest_punchline", to: "suggestions#suggest_punchline", as: :suggest_punchline

  resources :profiles, only: %i[show]
  resource :profile, only: %i[update], as: :self_profile
  devise_scope :user do
    get "profile/edit", to: "devise/registrations#edit", as: :edit_self_profile
  end

  resources :guests, only: %i[create]

  post "award", to: "awards#gift"
  
  get "/users/confirmation/new", to: redirect("users/edit")

  devise_scope :user do
    get "users/edit", to: redirect("profile/edit")
  end

  devise_for :users, controllers: {
    registrations: "users/registrations",
    confirmations: "users/confirmations"
  }

  get "up" => "rails/health#show", as: :rails_health_check
  
  get "turbo_redirect_to", controller: "application"

  root "games#index"
end
