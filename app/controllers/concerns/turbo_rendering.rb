module TurboRendering
  extend ActiveSupport::Concern

  included do
    # acts both as Application#turbo_redirect_to controller actions
    # and as a usual method to be called in other controllers
    after_action :store_flash, if: :turbo_redirect?

    def turbo_redirect_to(path = nil)
      skip_authorization if controller_name == "application"

      @turbo_redirect = true
      path ||= params[:path] || root_path
      # change to :see_other?
      render partial: "shared/redirect_to", formats: %i[turbo_stream], locals: { path: path }, status: :found
    end

    def render_turbo_flash(status: response.status)
      render partial: "shared/flash", formats: %i[turbo_stream], status: status
    end

    # very dirty! but since there are no before render callbacks...
    def render(*args)
      extract_flash if flashes_stored?
      super *args
    end

    private

    def turbo_redirect?
      @turbo_redirect
    end

    def flashes_stored?
      session[:flash_alert] || session[:flash_notice]
    end

    def store_flash
      session[:flash_alert] = flash[:alert] if flash[:alert]
      session[:flash_notice] = flash[:notice] if flash[:notice]
      @turbo_redirect = true
    end

    def extract_flash
      flash.now[:alert] = session.delete(:flash_alert)
      flash.now[:notice] = session.delete(:flash_notice)
    end
  end
end
