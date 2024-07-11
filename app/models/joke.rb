class Joke < ApplicationRecord
  include JokePlaying

  paginates_per 5

  belongs_to :punchline_author, class_name: :User
  belongs_to :setup_author, class_name: :User

  alias_method :user=, :punchline_author=
  alias_method :user, :punchline_author
end
