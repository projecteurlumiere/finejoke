module Localizable
  extend ActiveSupport::Concern

  included do
    # NEVER change order - append only
    enum locale: %i[en ru fr es]

    before_create :set_default_locale, unless: :locale_changed?

    def set_default_locale
      raise "must be implemented in the extended class #{self.class}"
    end
  end
end

