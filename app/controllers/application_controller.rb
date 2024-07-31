class ApplicationController < ActionController::Base
  include Pundit::Authorization
  include ErrorHandling
  include TurboRendering
  
  before_action :welcome_guest, if: :new_guest?, unless: :guest_welcomed?
  before_action :configure_permitted_parameters, if: :devise_controller?
  after_action :verify_authorized, unless: :devise_controller?
  after_action :remove_referrer, unless: %i[devise_controller? new_guest?] 

  def no_authentication_required?
    false
  end

  def pundit_user
    current_or_guest_user
  end

  def guest_user_params
    { username: "Joker" + SecureRandom.hex(10) }
  end

  private
  
  def guest_welcomed?
    session[:guest_welcomed]
  end


  def welcome_guest
    session[:guest_welcomed] = true if devise_controller?

    unless devise_controller?
      store_referrer
      authenticate_user!
    end
  end

  def store_referrer
    session[:referrer] = request.path
  end

  def after_sign_in_path_for(_resource)
    turbo_redirect_to_path(params: { path: session[:referrer]})
  end

  def remove_referrer
    session[:referrer] = nil
  end

  def new_guest?
    return false if current_user || session[:guest_user_id]

    true
  end

  helper_method :new_guest?

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:username])
    devise_parameter_sanitizer.permit(:account_update, keys: %i[email show_awards_allowed show_jokes_allowed])
  end

  def transfer_guest_to_user
    ActiveRecord::Base.transaction do
      current_user.merge(guest_user)
      guest_user.reload
    end
  end
end
