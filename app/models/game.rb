class Game < ApplicationRecord
  has_many :users # players 
  has_many :rounds, dependent: :destroy

  # after_create -> { broadcast_replace_to "lobby", partial: "games/list", locals: { games: Game.all }, target: "games" }

  broadcasts_to ->(entry) { "lobby" }, inserts_by: :prepend, partial: "games/entry"
  broadcasts_to ->(game) { ["game", game] }, inserts_by: :replace, partial: "games/game"

  def current_round
    self.rounds.last
  end

  def choose_lead
    lead = self.users.find_by(was_lead: false)
    if lead.nil?
      reset_lead
      lead = self.users.find_by!(was_lead: false)
    end

    self.users.update_all(lead: false)
    lead.set_lead

    lead
  end

  def reset_lead
    self.users.update_all(was_lead: false)
  end

  def reset_turns
    self.users.update_all(finished_turn: false)
  end
end
