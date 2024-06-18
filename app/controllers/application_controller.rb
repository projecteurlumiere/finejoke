class ApplicationController < ActionController::Base
  include Pundit::Authorization
  include ErrorHandling
  
  # after_action :verify_authorized, unless: :devise_controller?

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
end
