class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  belongs_to :game, optional: true

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
end
