module ErrorHandling
  extend ActiveSupport::Concern
  
  included do
    rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
    rescue_from Pundit::NotAuthorizedError, with: :render_not_authorized
    rescue_from ActionController::UnknownFormat, with: :render_unknown_format

    private

    def render_not_found
      flash.now.alert = t(:"application.not_found")
      response.status = :not_found

      if request.formats.include?(:turbo_stream)
        render_turbo_flash
      else
        render file: "#{Rails.root}/public/404.#{I18n.locale}.html", layout: false
      end
    end

    def render_not_authorized
      flash.now.alert = t(:"application.forbidden")
      response.status = :forbidden

      if request.formats.include?(:turbo_stream)
        render_turbo_flash
      else
        render file: "#{Rails.root}/public/403.#{I18n.locale}.html", layout: false
      end
    end

    def render_unknown_format
      flash.now.alert =  t(:"application.unknown_format")
      response.status = :unsupported_media_type

      render file: "#{Rails.root}/public/415.#{I18n.locale}.html", layout: false
    end
  end
end