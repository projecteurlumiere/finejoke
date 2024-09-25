module LocalesHandling
  extend ActiveSupport::Concern
  
  included do
    around_action :switch_locale

    def switch_locale(&action)
      user = current_user || (!new_guest? && current_or_guest_user)

      locale = user && 
               (user.locale || params[:locale] || I18n.default_locale)

      I18n.with_locale(locale, &action)
    end
  end
end