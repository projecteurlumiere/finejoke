class Setup < ApplicationRecord
  validates :text, length: { in: 1..Joke::SETUP_MAX_LENGTH }
  has_one :round
  has_many :jokes, dependent: :destroy
  belongs_to :user

  before_update -> { self.text_short = self.class.truncate(text) }, if: :text_changed?


  def self.truncate(setup)
    return if setup.length < Joke::SETUP_TRUNCATE_LENGTH

    string = setup.dup

    str_modified = if !string.end_with?(*%w[. ! ?])
                     string.concat(".")
                     true
                   end

    sentences = string.scan(/[^\.!?]+[\.!?:# ]/).map(&:strip)
    last_sentence = sentences.pop
    last_sentence.slice!(-1) if str_modified

    if last_sentence.length > Joke::SETUP_TRUNCATE_LENGTH
      shorter_sentence = []

      last_sentence.split(" ").reverse.inject(0) do |sum, word|
        length = sum + word.length
        length > Joke::SETUP_TRUNCATE_LENGTH ? break : shorter_sentence << word
        length
      end

      if shorter_sentence.none?
        shorter_sentence << last_sentence.slice(-Joke::SETUP_TRUNCATE_LENGTH..-1)
      else 
        shorter_sentence.reverse
      end.join(" ")
    else
      last_sentence
    end
  end
end