class LocalesController < ApplicationController
  def update
    skip_authorization
    set_locale
    
    # updating locale if there is a guest user
    if params[:locale] && !new_guest?
      current_or_guest_user.update(locale: @locale)
    end

    path = set_redirect_path

    redirect_to(path, status: :see_other)
  end

  private

  def set_locale
    locale = params[:locale].to_sym
    @locale = I18n.available_locales.include?(locale) ? locale : I18n.default_locale
  end

  def no_authentication_required?
    true
  end

  def set_redirect_path
    return root_path(params: { locale: @locale }) unless params[:current_page]

    url =  params[:current_page]
    replace_query_param(url, "locale", @locale)
  end
end
