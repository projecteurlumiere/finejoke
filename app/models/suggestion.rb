class Suggestion < ApplicationRecord
  has_and_belongs_to_many :jokes, dependent: :nullify

  enum target: %i[setup punchline], _prefix: :for 

  attr_accessor *%i[
    user 
    game_id game 
    round_id round 
    context user_input
  ]

  with_options if: :new_record? do |model| 
    model.validates :user, presence: true
    model.validates :game_id, presence: true
    model.validates :game, presence: true
    model.validates :round_id, presence: true
    model.validates :round, presence: true
    model.validate -> { 
      errors.add(:game, "user must be playing the game and round")
    }, unless: :user_playing?
    
    model.validate -> { 
      errors.add(:context, "not allowed to have context for setup generation")
    }, if: %i[for_setup? context] 

    model.validate -> { 
      errors.add(:for, "user must be lead to request setup suggestion")
    }, if: :for_setup?, unless: :user_lead?

    model.validate -> { 
      errors.add(:for, "user must not be lead to request punchline suggestion") unless !user.lead? 
    }, if: %i[for_punchline? user_lead?]

    model.validate -> {
      errors.add(:user, "not enough credits")
    }, unless: :user_can_afford?
  end

  validates :target, presence: true

  before_validation :generate, if: :new_record?
  validates :output, presence: true

  after_initialize -> {
    self.game = Game.find_by(id: game_id)
    self.round = Round.find_by(id: round_id)
    self.context = round&.setup
  }, if: :new_record?

  after_create -> { 
    user.suggestions << id
    user.total_suggestions += 1
    user.save!
  }

  def user_playing?
    user&.playing?(game) && user&.playing?(round)
  end

  def user_lead?
    user.lead?
  end

  def user_can_afford?
    user.enough_credits?(price: 1)
  end

  def generate
    return unless user.pay(price: 1)

    self.output = (case self.target.to_sym
    when :setup
      "I am a funny and very very very very very very very very very long and longing setup"
    when :punchline
      "I am a funny and very very very very very very very very very long and longing punch"
    end + " your previous response was: #{user_input || "there was not any"}").slice(0..(Joke::SETUP_MAX_LENGTH - 1))
  end
end