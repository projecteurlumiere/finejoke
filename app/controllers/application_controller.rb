class ApplicationController < ActionController::Base
  include LocalesHandling
  include Pundit::Authorization
  include TurboRendering
  include ErrorHandling

  layout "layouts/application"
  
  before_action :welcome_guest, if: :new_guest?, unless: :guest_welcomed?
  before_action :authenticate_user!, unless: %i[no_authentication_required?] 
  before_action :configure_permitted_parameters, if: :devise_controller?
  after_action :verify_authorized, unless: :devise_controller?
  after_action :remove_referrer, unless: %i[devise_controller? new_guest?]

  private
  
  def pundit_user
    current_or_guest_user
  end

  # overriide this in controller to bypass authentication
  def no_authentication_required?
    devise_controller? || current_user || guest_welcomed?
  end

  def authentication_required_for_ai?
    ENV.fetch("ENABLE_AUTHENTICATION_FOR_AI", "").present?
  end

  def guest_welcomed?
    session[:guest_welcomed]
  end

  def new_guest?
    return false if current_user || session[:guest_user_id]

    true
  end

  helper_method :new_guest?

  def welcome_guest
    flash[:notice] = t(:"application.welcome_guest")

    store_referrer unless no_authentication_required?
  end

  def store_referrer
    session[:referrer] = request.path
  end

  def remove_referrer
    session[:referrer] = nil
  end


  def after_sign_in_path_for(_resource)
    if request.formats.include?(:turbo_stream)
      turbo_redirect_to_path(params: { path: session[:referrer]})
    else
      session[:referrer] || root_path
    end
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:username])
    devise_parameter_sanitizer.permit(:account_update, keys: %i[username email show_awards_allowed show_jokes_allowed locale])
  end

  def transfer_guest_to_user
    return if (Time.now - User.last.created_at) / 86400 > 1 # should not merge user is at least 1 days old

    ActiveRecord::Base.transaction do
      guest_user.game&.remove_user(guest_user)
      current_user.merge(guest_user)
      guest_user.reload
    end
  end
end
