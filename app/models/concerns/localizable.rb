module Localizable
  extend ActiveSupport::Concern

  included do
    # NEVER change order - append only
    enum locale: I18n.available_locales

    before_create :set_default_locale, unless: :locale_changed?

    def set_default_locale
      raise "must be implemented in the extended class #{self.class}"
    end
  end
end
