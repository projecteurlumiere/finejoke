class Suggestion < ApplicationRecord
  include Localizable

  has_and_belongs_to_many :jokes, dependent: :nullify

  SETUP_MAX_TOKENS = Joke::SETUP_MAX_LENGTH / 4 * 3
  PUNCHLINE_MAX_TOKENS = Joke::PUNCHLINE_MAX_LENGTH / 4 * 3
  CONTEXT_MAX_LENGTH = 500
  USER_INPUT_MAX_LENGTH = 500

  enum target: %i[setup punchline], _prefix: :for 

  attr_accessor *%i[
    user 
    game_id game 
    round_id round 
    force_creation
    error
  ]

  with_options if: :new_record?, unless: :force_creation do |model|
    model.validates :user, presence: true
    model.validates :game_id, presence: true
    model.validates :game, presence: true
    model.validates :round_id, presence: true
    model.validates :round, presence: true
  end

  validates :target, presence: true

  before_validation -> { 
    self.context = nil unless context.present?
    self.user_input = nil unless user_input.present?
  }

  validates_with SuggestionValidator, on: :create, if: :new_record?, unless: :force_creation
  validates :context, length: { in: 1..CONTEXT_MAX_LENGTH }, if: :context
  validates :user_input, length: { in: 1..USER_INPUT_MAX_LENGTH }, if: :user_input

  after_initialize -> {
    self.game = Game.find_by(id: game_id)
    self.round = Round.find_by(id: round_id)
    self.context = round&.setup
  }, if: :new_record?

  before_create :generate

  after_create :add_suggestion_to_user

  def set_default_locale
    self.locale = game.locale
  end

  def user_playing?
    user&.playing?(game) && user&.playing?(round)
  end

  def user_lead?
    user&.lead?
  end

  def user_can_afford?
    user&.enough_credits?(price: 1)
  end

  def generate
    params = prepare_params
    ai_response = make_request(**params)
    self.output = ai_response["choices"][0]["message"]["content"]
  rescue => e
    self.error = e
    reuse_previous_suggestion
  end

  def prepare_params
    if for_setup?
      {
        max_tokens: SETUP_MAX_TOKENS,
        system_message: request_setup_message
      }
    elsif for_punchline?
      {
        max_tokens: PUNCHLINE_MAX_TOKENS,
        system_message: request_punchline_message
      }
    end
  end

  def request_setup_message
    <<~HEREDOC
      You are a comedian assistant.
      Your job is to suggest funniest and spiciest jokes. Topics can be any.
      Right now you have to suggest a funny setup.
      The message you receive (if you receive one at all) is user's
      attempt to write a hilarious setup. You can either rewrite this attempt
      into something funnier or you may discard it altogether.
      You do not write punchline or anything else. Setup only.
      It must be structured so that user can continue it.
      Your response must be in #{locale} language.
      Your response may be short or long, but no more than #{Joke::SETUP_MAX_LENGTH} symbols.
    HEREDOC
  end

  def request_punchline_message
    <<~HEREDOC
      You are a comedian assistant.
      Your job is to suggest funniest and spiciest jokes.
      The first message you receive is a setup.
      The second message you receive (if you receive it at all) is user's
      attempt to write something funny. You can either rewrite this attempt
      into something funnier or you may discard it altogether.
      You respond by one punchline connected to the setup only.
      You do not write setup or anything else. Punchline only.
      Your response must be in #{locale} language.
      Your response may be short or long, but no more than #{Joke::PUNCHLINE_MAX_LENGTH} symbols.
    HEREDOC
  end

  def make_request(system_message:, max_tokens:)
    OpenAI::Client.new.chat(
      parameters: { 
        model: "gpt-4o-mini",
        temperature: 0.8,
        max_tokens: max_tokens,
        messages: [
          {
            role: "system",
            content: system_message
          },
          ({
            role: "user",
            content: context
          } if context),
          ({
            role: "user",
            content: user_input
          } if user_input)
        ].compact
      }
    )
  end

  def reuse_previous_suggestion
    throw :abort unless for_setup?

    old_suggestion = Suggestion
                     .where(user_input: nil)
                     .order("RANDOM()")
                     .limit(1)
                     .pluck(:id, :output)[0]

    throw :abort if old_suggestion.none?

    add_suggestion_to_user(old_suggestion[0])
    self.output = old_suggestion[1]
  end

  def add_suggestion_to_user(id = self.id)
    return unless user
    
    user.suggestions << id
    user.total_suggestions += 1
    user.save!
  end
end