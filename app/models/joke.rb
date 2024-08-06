class Joke < ApplicationRecord
  include JokePlaying

  paginates_per 5

  belongs_to :punchline_author, class_name: :User
  belongs_to :setup_author, class_name: :User
  validates :setup, length: { in: 1..200 }
  validates :punchline, length: { in: 1...200 } 

  alias_method :user=, :punchline_author=
  alias_method :user, :punchline_author
end
