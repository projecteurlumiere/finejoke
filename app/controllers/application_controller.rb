class ApplicationController < ActionController::Base
  rescue_from ActiveRecord::RecordNotFound, with: :redirect_to_root
  rescue_from ActionController::RoutingError, with: :redirect_to_root

  def redirect_to_root
    render file: "#{Rails.root}/public/404.html", status: :not_found, alert: "not found!"
  end

  def render_turbo_flash(notice: nil, alert: nil)
    flash.now[:notice] = notice if notice
    flash.now[:alert] = alert if alert
  end
end
