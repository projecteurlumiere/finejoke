class Joke < ApplicationRecord
  include JokePlaying

  paginates_per 5

  belongs_to :punchline_author, class_name: :User
  belongs_to :setup_author, class_name: :User

  validate -> { game.present? && round.present? }, if: :new_record?
  SETUP_MAX_LENGTH = 350
  SETUP_TRUNCATE_LENGTH = 50
  PUNCHLINE_MAX_LENGTH = 350

  validates :setup, length: { in: 1..SETUP_MAX_LENGTH }
  validates :punchline, length: { in: 1...PUNCHLINE_MAX_LENGTH }

  alias_method :user=, :punchline_author=
  alias_method :user, :punchline_author
end
