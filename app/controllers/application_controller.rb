class ApplicationController < ActionController::Base
  include Pundit::Authorization
  include ErrorHandling

  def render_turbo_flash(notice: nil, alert: nil)
    flash.now[:notice] = notice if notice
    flash.now[:alert] = alert if alert
  end
end
