class Present < ApplicationRecord
  has_many :awards, dependent: :destroy
end