class Suggestion
  include ActiveModel::API

  attr_accessor *%i[
    user 
    game_id game 
    round_id round 
    for context user_input
  ]

  validates :user, presence: true

  validates :game_id, presence: true
  validates :game, presence: true
  validates :round_id, presence: true
  validates :round, presence: true
  validate -> { 
    errors.add(:game, "user must be playing the game") unless user&.playing?(game)  
    errors.add(:round, "user must be playing the round") unless user&.playing?(round) 
  }

  validates :for, presence: true, inclusion: { in: %i[setup punchline] }
  
  validate -> { 
    errors.add(:for, "not allowed to have context for setup") if context 
  }, if: :for_setup?

  validate -> { 
    errors.add(:for, "user must be lead to request setup suggestion") unless user.lead?
  }, if: :for_setup?

  validate -> { 
    errors.add(:for, "user must not be lead to request punchline suggestion") unless !user.lead? 
  }, if: :for_punchline?

  def initialize(*args)
    super *args

    self.for = self.for.to_sym if %w[setup punchline].include?(self.for)

    self.game = Game.find_by(id: game_id)
    self.round = Round.find_by(id: round_id)
    self.context = round&.setup
  end

  def generate
    (case self.for
    when :setup
      "I am a funny and very very very very very very very very very long and longing setup"
    when :punchline
      "I am a funny and very very very very very very very very very long and longing punch"
    end + " your previous response was: #{user_input || "there was not any"}").slice(0..(Joke::SETUP_MAX_LENGTH - 1))
  end

  def for_setup?
    self.for == :setup
  end

  def for_punchline?
    self.for == :punchline
  end
end