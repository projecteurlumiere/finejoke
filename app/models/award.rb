class Award < ApplicationRecord
  include Localizable

  paginates_per 10

  # TODO who is gifted and who is gifter?
  belongs_to :user
  belongs_to :present

  delegate :name, :description, :icon, to: :present

  def set_default_locale
    self.locale = user.locale
  end
end
