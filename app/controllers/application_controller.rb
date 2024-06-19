class ApplicationController < ActionController::Base
  include Pundit::Authorization
  include ErrorHandling
  
  before_action :store_referrer, :authenticate_user!, if: :new_guest?, unless: :devise_controller?
  before_action :configure_permitted_parameters, if: :devise_controller?
  after_action :verify_authorized, unless: :devise_controller?

  def render_turbo_flash(notice: nil, alert: nil)
    flash.now[:notice] = notice if notice
    flash.now[:alert] = alert if alert
  end

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

  def store_referrer
    session[:referrer] = request.path
  end

  def after_sign_in_path_for(resource)
    session.delete(:referrer) || root_path
  end

  def new_guest?
    return false if current_user || session[:guest_user_id]

    true
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:username])
  end
end
