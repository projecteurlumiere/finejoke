class ApplicationController < ActionController::Base
  include Pundit::Authorization
  include TurboRendering
  include ErrorHandling

  layout "layouts/application"
  
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

  private
  
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

    unless devise_controller? || controller_name == "guests"
      store_referrer
      authenticate_user!
    end
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
    devise_parameter_sanitizer.permit(:account_update, keys: %i[username email show_awards_allowed show_jokes_allowed])
  end

  def transfer_guest_to_user
    ActiveRecord::Base.transaction do
      guest_user.game&.remove_user(guest_user)
      current_user.merge(guest_user)
      guest_user.reload
    end
  end
end
