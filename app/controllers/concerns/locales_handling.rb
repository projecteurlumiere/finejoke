module LocalesHandling
  extend ActiveSupport::Concern
  
  included do
    around_action :switch_locale

    def switch_locale(&action)
      user = current_user || (!new_guest? && current_or_guest_user)

      # user can be false sometimes, not just nil
      locale = (user && user.locale) || 
               params[:locale] ||
               extract_locale_from_accept_language_header ||
               I18n.default_locale

      I18n.with_locale(locale, &action)
    end

    private 

    def extract_locale_from_accept_language_header
      locale = request.env["HTTP_ACCEPT_LANGUAGE"].scan(/^[a-z]{2}/).first.to_sym
      locale if I18n.locale_available?(locale)
    end
  end
end