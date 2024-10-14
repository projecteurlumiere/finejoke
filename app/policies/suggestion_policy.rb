class SuggestionPolicy < ApplicationPolicy
  attr_reader :user, :suggestion

  def initialize(user, suggestion)
    @user = user
    @suggestion = suggestion
    @game = @suggestion.try(:game)
  end

  def suggest_setup?
    ai_allowed? && 
      @user&.playing?(@game) && 
      @game&.current_round.setup_stage? && 
      authenticated_for_ai?
  end

  def suggest_punchline?
    ai_allowed? && 
      @user&.playing?(@game) && 
      @game&.current_round.punchline_stage? && 
      authenticated_for_ai?
  end

  # it gets additionally authorized in the respective controller. careful!
  def show_quota?
    true
  end
  
  private 

  def ai_allowed?
    ENV["OPENAI_ACCESS_TOKEN"].present? && Suggestion.enabled? && @game&.suggestable?
  end

  def authenticated_for_ai?
    return true if ENV.fetch("ENABLE_AUTHENTICATION_FOR_AI", "").blank?

    return true if @user.present? && !@user.guest? && @user.confirmed?

    @error_message_key = if @user.blank? || @user.guest?
                           :"devise.failure.unauthenticated"
                         elsif !@user.confirmed?
                           :"devise.failure.unconfirmed"
                         end

    false
  end
end