class Setup < ApplicationRecord
  include Localizable

  MAX_LENGTH = Joke::SETUP_MAX_LENGTH
  TRUNCATE_LENGTH = Joke::SETUP_TRUNCATE_LENGTH

  validates :text, length: { in: 1..MAX_LENGTH }
  # has_one :round
  # has_one :game, through: :round
  has_many :jokes, dependent: :destroy
  belongs_to :user, optional: true

  before_save -> { self.text_short = self.class.truncate(text) }, if: :text_changed?

  def set_default_locale; end

  def self.truncate(setup)
    return if setup.length < TRUNCATE_LENGTH

    string = setup.dup

    str_modified = if !string.end_with?(*%w[. ! ?])
                     string.concat(".")
                     true
                   end
    sentences = string.scan(/[^\.!?]+[\.!?:»'"# ]+/).map(&:strip)
    last_sentence = sentences.pop
    last_sentence.slice!(-1) if str_modified

    if last_sentence.length > TRUNCATE_LENGTH
      shorter_sentence = []

      last_sentence.split(" ").reverse.inject(0) do |sum, word|
        length = sum + word.length
        length > TRUNCATE_LENGTH ? break : shorter_sentence << word

        length
      end

      if shorter_sentence.none?
        shorter_sentence << last_sentence.slice(-TRUNCATE_LENGTH..-1)
      else 
        shorter_sentence.reverse
      end.join(" ")
    else
      last_sentence
    end
  end
end