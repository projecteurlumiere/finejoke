class ApplicationController < ActionController::Base
  include Pundit::Authorization
  include ErrorHandling
  before_action :authenticate_user!, unless: :devise_controller?
  after_action :verify_authorized, unless: :devise_controller?

  def render_turbo_flash(notice: nil, alert: nil)
    flash.now[:notice] = notice if notice
    flash.now[:alert] = alert if alert
  end
end
