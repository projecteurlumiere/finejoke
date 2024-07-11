class Joke < ApplicationRecord
  include JokePlaying

  paginates_per 5

  belongs_to :user
  belongs_to :punchline_author, class_name: :User
end
