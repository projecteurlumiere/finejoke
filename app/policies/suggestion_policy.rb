class SuggestionPolicy < ApplicationPolicy
  attr_reader :user, :suggestion

  def initialize(user, suggestion)
    @user = user
    @suggestion = suggestion
    @game = @suggestion.game
  end

  def suggest_setup?
   @game&.ai_allowed? && @user&.playing?(@game) && @game.current_round.setup_stage? 
  end

  def suggest_punchline?
    @game&.ai_allowed? && @user&.playing?(@game) && @game.current_round.punchline_stage?
  end
end