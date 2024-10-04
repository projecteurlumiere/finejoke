class RootController < ApplicationController
  def show
    skip_authorization

    redirect_to_devise if !current_user
  end

  private

  def no_authentication_required?
    true
  end

  def redirect_to_devise
    locale = params.fetch(:locale, I18n.locale)
    params_for_redirect = { params: { locale: } }

    path = new_user_session_path(**params_for_redirect)
    
    # if params[:current_page] == "new-registration"
    #   new_user_registration_path(**params_for_redirect)
    # else
      # new_user_session_path(**params_for_redirect)
    # end

    redirect_to path, status: :see_other
  end
end
