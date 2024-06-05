class ApplicationController < ActionController::Base
  include Pundit::Authorization
  include ErrorHandling
  after_action :verify_authorized

  def render_turbo_flash(notice: nil, alert: nil)
    flash.now[:notice] = notice if notice
    flash.now[:alert] = alert if alert
  end
end
