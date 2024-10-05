class SuggestionValidator < ActiveModel::Validator
  def validate(s)
    s.errors.add(:game, "user must be playing the game and round") unless s.user_playing?
    s.errors.add(:user, "user exceeded suggestion quota") unless s.user.suggestion_quota.positive? 
    s.errors.add(:context, "not allowed to have context for setup generation") if s.for_setup? & s.context
    s.errors.add(:for, "user must be lead to request setup suggestion") if s.for_setup? && !s.user_lead?
    s.errors.add(:for, "user must not be lead to request punchline suggestion") if s.for_punchline? && s.user_lead?
  end
end
