class SuggestionPolicy < ApplicationPolicy
  attr_reader :user, :suggestion

  def initialize(user, suggestion)
    @user = user
    @suggestion = suggestion
  end

  def suggest_setup?
    @suggestion.game.ai_allowed?
  end

  def suggest_punchline?
    @suggestion.game.ai_allowed?
  end
end