class LocalesController < ApplicationController
  def update
    skip_authorization
    # updating locale if there is a guest user
    
    if params[:locale] && !new_guest?
      current_or_guest_user.update(locale: params[:locale])
    end

    redirect_to((params[:current_page] || root_path), params: { locale: I18n.locale }, status: :see_other)
  end

  private

  def no_authentication_required?
    true
  end
end
