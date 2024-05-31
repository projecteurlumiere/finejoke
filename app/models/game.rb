class Game < ApplicationRecord
  has_many :users # players 
  has_many :rounds, dependent: :destroy

  # after_create -> { broadcast_replace_to "lobby", partial: "games/list", locals: { games: Game.all }, target: "games" }

  broadcasts_to ->(entry) { "lobby" }, inserts_by: :prepend, partial: "games/entry"
  broadcasts_to ->(game) { ["game", game] }, inserts_by: :replace, partial: "games/game"

  def choose_lead
    user = self.users.find_by(was_lead: false)
    if user.nil?
      reset_lead
      user = self.users.find_by!(was_lead: false)
    end

    user.update(lead: true, was_lead: true)
    user
  end

  def reset_lead
    self.users.update_all(was_lead: false)
  end
end
