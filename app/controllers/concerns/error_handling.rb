module ErrorHandling
  extend ActiveSupport::Concern
  
  included do
    # rescue_from Pundit::NotAuthorizedError, with: :render_not_authorized
    # rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
    # rescue_from ActionController::UnknownFormat, with: :render_not_acceptable

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

    def render_not_acceptable
      response.status = :not_acceptable
      flash.now[:alert] ||= t(:"application.unacceptable")

      render "errors/message", locals: { code: 406 }
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

    def with_custom_pundit_error_message
      yield
    rescue Pundit::NotAuthorizedError => e
      flash.now[:alert] = t(e.policy.error_message_key, default: t(:"application.forbidden"))
      raise e
    end
  end
end