class Prompt < ApplicationRecord
  include Localizable
  # include Voicable

  belongs_to :virtual_host
  has_one :game, through: :virtual_host

  def set_default_locale
    self.locale = virtual_host.locale
  end
end