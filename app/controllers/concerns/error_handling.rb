module ErrorHandling
  extend ActiveSupport::Concern 
  included do 
    rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
    rescue_from ActionController::RoutingError, with: :render_not_found

    def render_not_found
      render file: "#{Rails.root}/public/404.html", status: :not_found, alert: "not found!"
    end
  end
end