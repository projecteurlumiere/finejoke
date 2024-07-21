module TurboRendering
  extend ActiveSupport::Concern

  included do
    # acts both as Application#turbo_redirect_to controller actions
    # and as a usual method to be called in other controllers
    def turbo_redirect_to(path = nil)
      skip_authorization if controller_name == "application"

      path ||= params[:path] || root_path
      render partial: "shared/redirect_to", formats: %i[turbo_stream], locals: { path: path }, status: :found
    end

    def render_turbo_flash(status: response.status)
      render partial: "shared/flash", formats: %i[turbo_stream], status: status
    end
  end
end
