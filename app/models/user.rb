class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  belongs_to :game, optional: true

  validates :username, presence: true

  def set_lead
    self.update(lead: true, was_lead: true)
  end

  def finished_turn!
    update_attribute(:finished_turn, true)
    broadcast_turn_finished
  end

  def voted!
    update_attribute(:voted, true)
    broadcast_vote_finished
  end

  def reset_game_attributes
    self.update({ 
      game_id: nil,
      host: false,
      lead: false,
      finished_turn: false,
      voted: false,
      current_score: 0
    })
  end

  def broadcast_status_change
    broadcast_render_later_to(["user", self], partial: "layouts/user_status", formats: %i[turbo_stream], locals: { game_id: game&.id || 0 }) 
  end

  def broadcast_turn_finished
    broadcast_render_later_to(["game", game], partial: "games/game_user", formats: %i[turbo_stream], locals: { user_id: id, game_id: game.id }) 
  end

  alias_method :broadcast_vote_finished, :broadcast_turn_finished
end
