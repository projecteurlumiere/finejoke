class LocalesController < ApplicationController
  def update
    skip_authorization
    # updating locale if there is a guest user
    
    if params[:locale] && !new_guest?
      current_or_guest_user.update(locale: params[:locale])
    end

    path = set_redirect_path

    redirect_to(path, status: :see_other)
  end

  private

  def no_authentication_required?
    true
  end

  def set_redirect_path
    return root_path(params: { locale: I18n.locale }) unless params[:current_page]

    url =  params[:current_page]
    uri = URI.parse(url)

    # parsing query into hash
    query = Rack::Utils.parse_query(uri.query)

    # Replace the value
    query["locale"] = I18n.locale

    uri.query = Rack::Utils.build_query(query)
    uri.to_s
  end
end