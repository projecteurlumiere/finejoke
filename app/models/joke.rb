class Joke < ApplicationRecord
  include JokePlaying

  has_and_belongs_to_many :suggestions, dependent: :nullify

  paginates_per 5

  belongs_to :user
  belongs_to :setup_model, class_name: :Setup, autosave: true

  validate -> { game.present? && round.present? }, if: :new_record?
  SETUP_MAX_LENGTH = 350
  SETUP_TRUNCATE_LENGTH = 50
  PUNCHLINE_MAX_LENGTH = 350

  # validates :setup, length: { in: 1..SETUP_MAX_LENGTH }
  validates :punchline, length: { in: 1...PUNCHLINE_MAX_LENGTH }

  alias_method :punchline_author=, :user=
  alias_method :punchline_author, :user

  def text
    "#{setup} #{punchline}"
  end

  def setup_author
    setup_model.user
  end

  def setup
    setup_model.text
  end

  def setup_short
    setup_model.text_short
  end
end
