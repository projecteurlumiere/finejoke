Rails.application.routes.draw do
  resources :games, except: %i[new edit update destroy] do
    post "join", to: "games#join"
    post "leave", to: "games#leave"
    post "kick", to: "games#kick"
    get "rules", to: "games#show_rules"
    get "over", to: "games#game_over"
    
    get "rounds/current", to: "rounds#show_current"
    post "rounds/:id/skip_results", to: "rounds#skip_results", as: :round_skip_results
    
    resources :rounds, only: %i[show create update] do
      resources :jokes, only: %i[create]
      patch "/jokes/:id/vote", to: "jokes#vote", as: :joke_vote
    end

    resources :messages, only: %i[create]
  end

  post "suggest_setup", to: "suggestions#suggest_setup", as: :suggest_setup
  post "suggest_punchline", to: "suggestions#suggest_punchline", as: :suggest_punchline
  get "show_quota", to: "suggestions#show_quota", as: :suggestion_quota

  resources :profiles, only: %i[show]
  
  # devise redirection to beautified links
  devise_scope :user do
    get "/users/sign_in", to: redirect(path: "/sign_in")
    get "/users/sign_up", to: redirect(path: "/sign_up")
    get "/users/password/new", to: redirect(path: "/forgot_password")
  end

  devise_for :users, controllers: {
    confirmations: "users/confirmations",
    passwords: "users/passwords",
    registrations: "users/registrations",
    sessions: "users/sessions"
  }

  authenticated :user do
    root "root#show", as: :authenticated_root
  end

  devise_scope :user do
    get "profile/edit", to: "devise/registrations#edit", as: :edit_self_profile
    # prettier paths but still use old helpers:
    get "/sign_in", to: "users/sessions#new"
    get "/sign_up", to: "users/registrations#new"

    get "/users/password/new", to: redirect(path: "/forgot_password")
    get "/forgot_password", to: "users/passwords#new"

    root "users/sessions#new"
  end

  resources :guests, only: %i[create]
  resource :locale, only: %i[update]

  post "award", to: "awards#gift"
  
  get "/users/confirmation/new", to: redirect("users/edit")

  devise_scope :user do
    get "users/edit", to: redirect("profile/edit")
  end

  get "up" => "rails/health#show", as: :rails_health_check
  
  get "turbo_redirect_to", controller: "application"

  match "/403", via: :all, to: "errors#not_authorized"
  match "/404", via: :all, to: "errors#not_found"
  match "/406", via: :all, to: "errors#not_acceptable"
  match "/500", via: :all, to: "errors#internal_server_error"
end
