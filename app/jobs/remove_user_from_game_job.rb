class RemoveUserFromGameJob < ApplicationJob
  queue_as :urgent

  def perform(user_id, game_id)
    game = Game.find_by(id: game_id)
    user = User.find_by(id: user_id)

    game&.remove_user(user)
  end
end
