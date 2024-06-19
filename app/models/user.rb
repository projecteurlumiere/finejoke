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
    broadcast_render_later_to(["user", self], partial: "games/user_status", formats: %i[turbo_stream], locals: { game_id: game&.id || 0 }) 
  end
end
