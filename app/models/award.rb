class Award < ApplicationRecord
  paginates_per 10

  belongs_to :user
  belongs_to :present

  delegate :name, :description, :icon, to: :present
end
