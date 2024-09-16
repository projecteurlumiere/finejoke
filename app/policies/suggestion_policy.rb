class SuggestionPolicy < ApplicationPolicy
  attr_reader :user, :suggestion

  def initialize(user, suggestion)
    @user = user
    @suggestion = suggestion
    @game = @suggestion.game
  end

  def suggest_setup?
   ai_allowed? && @user&.playing?(@game) && @game.current_round.setup_stage? 
  end

  def suggest_punchline?
    ai_allowed? && @user&.playing?(@game) && @game.current_round.punchline_stage?
  end

  private 

  def ai_allowed?
    ENV["OPENAI_ACCESS_TOKEN"].present? && @game&.ai_allowed? && @game&.ai_allowed?
  end
end