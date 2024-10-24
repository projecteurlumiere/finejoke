class Suggestion < ApplicationRecord
  include Localizable
  include Disableable

  # when disabled, suggestions won't be visible & won't pass pundit check
  DISABLEABLE_KEY = "DISABLE_SUGGESTION".freeze
  TOPICS = YAML.load(File.read(File.join(Rails.root.join("db", "yml", "joke_topics.yml")))).freeze
  
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

  before_create :charge_user, unless: :force_creation
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

  def charge_user
    user.decrement!(:suggestion_quota)
  end

  def generate
    params = prepare_params
    ai_response = make_request(**params)
    self.output = ai_response["choices"][0]["message"]["content"]
  rescue => e
    self.error = e
    throw :abort
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
      Right now you have to suggest a joke's beginning, setup.
      The topic for this one is #{TOPICS.sample(1)}
      It is mandatory that your response is unfinished and does not contain the funniest part. 
      Just like a setup would be.
      You must tailor it so that it finished with "...", 
      that is expecting the user to continue it with his own punchline.
      Whatever you receive from the user (if you receive anything), treat it as a setup draft.
      You can either completely rewrite this draft into something funnier
      or you may discard it altogether and write a completely new setup.
      You must not attempt to continue whatever user sent you: 
      your job is to compose a joke's beginning. 
      Under no circumstances should you response with a finished joke.
      Your response must be in #{locale} language.
      Your response may be short or long, but no more than #{Joke::SETUP_MAX_LENGTH} symbols.
    HEREDOC
  end

  def request_punchline_message
    <<~HEREDOC
      You are a comedian assistant.
      You assist in creation of funniest and spiciest jokes. 
      Right now you have to suggest a hilarious joke's ending, punchline.
      You must respond with one punchline connected to the setup,
      which is the first message you receive.
      Whatever the content of the first message is, treat it as a joke's beginning, setup.
      You must not write anything but punchline to the setup.
      You must not reply to the second message you receive (if you receive one at all) as
      it is user's attempt to write a hilarious punchline. 
      Whatever the second message is, treat it as a punchline draft.
      You can either rewrite this draft into something funnier
      or you may discard it altogether.
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
    return unless for_setup?

    old_suggestion = Suggestion
                     .where(user_input: nil, locale:, target:)
                     .order("RANDOM()")
                     .limit(1)
                     .pluck(:id, :output)[0]

    return if old_suggestion.blank?

    transaction do 
      charge_user
      add_suggestion_to_user(old_suggestion[0])
      self.output = old_suggestion[1]
    end
    logger.warn "Suggestion with id #{old_suggestion[0]} was reused"
    user.reload
  end

  def add_suggestion_to_user(id = self.id)
    return unless user
    
    user.suggestions << id
    user.total_suggestions += 1
    user.save!
  end
end