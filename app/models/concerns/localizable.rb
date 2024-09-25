module Localizable
  extend ActiveSupport::Concern

  included do
    # NEVER change order - append only
    before_create :set_default_locale, unless: :locale
    enum locale: %i[en ru fr es]

    def set_default_locale
      raise "must be implemented in extended classes"
    end
  end
end

