module ErrorHandling
  extend ActiveSupport::Concern
  
  included do 
    private 

    def turbo_redirect_to(path)
      render partial: "shared/redirect_to", locals: { path: path }, status: :found
    end

    def render_turbo_flash(status:)
      render partial: "shared/flash", status: status
    end
  end
end