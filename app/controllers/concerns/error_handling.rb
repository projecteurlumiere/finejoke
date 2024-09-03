module ErrorHandling
  extend ActiveSupport::Concern
  
  included do 
    rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
    rescue_from Pundit::NotAuthorizedError, with: :render_not_authorized

    private

    def render_not_found
      flash.now.alert = t("application.not_found")
      status = :not_found

      if request.formats.include?(:turbo_stream)
        render_turbo_flash(status:)
      else
        render file: "#{Rails.root}/public/404.html", layout: false, status:
      end
    end

    def render_not_authorized
      flash.now.alert = t("application.forbidden")
      status = :forbidden

      if request.formats.include?(:turbo_stream)
        render_turbo_flash(status:)
      else
        render file: "#{Rails.root}/public/403.html", layout: false, status:
      end
    end
  end
end