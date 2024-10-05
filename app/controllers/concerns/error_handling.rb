module ErrorHandling
  extend ActiveSupport::Concern
  
  included do
    rescue_from Pundit::NotAuthorizedError, with: :render_not_authorized
    rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
    rescue_from ActionController::UnknownFormat, with: :render_unknown_format

    private

    def render_not_authorized
      response.status = :forbidden
      flash.now[:alert] ||= t(:"application.forbidden")

      if request.formats.include?(:turbo_stream)
        render_turbo_flash
      else
        render "errors/message", locals: { code: 403 }
      end
    end

    def render_not_found
      response.status = :not_found
      flash.now[:alert] = t(:"application.not_found")

      if request.formats.include?(:turbo_stream)
        render_turbo_flash
      else
        render "errors/message", locals: { code: 404 }
      end
    end

    def render_unknown_format
      response.status = :unsupported_media_type
      flash.now[:alert] ||= t(:"application.unknown_format")

      render "errors/message", locals: { code: 415 }
    end

    def render_internal_server_error
      response.status = :internal_server_error
      flash.now[:alert] ||= t(:"application.internal_server_error")

      if request.formats.include?(:turbo_stream)
        render_turbo_flash
      else
        render "errors/message", locals: { code: 500 }
      end
    end
  end
end