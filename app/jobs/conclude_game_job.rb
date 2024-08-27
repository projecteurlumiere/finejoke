class ConcludeGameJob < ApplicationJob
  queue_as :default

  # def perform(game_id, last_updated_at = nil, force: false)
  #   game = Game.find_by(id: game_id)
  #   return unless game

  #   if !force && game.updated_at > last_updated_at
  #     game.schedule_game_conclude(concluded:) if game.waiting? || game.on_halt?
  #     return
  #   end

  #   game.conclude
  # end


  def perform(game_id, last_updated_at = nil, notify:, force:)
    game = Game.find_by(id: game_id)
    return unless game

    if !force && game.updated_at.after?(last_updated_at)
      game.schedule_game_conclude(notify: true, force:) if game.waiting? || game.on_halt?
      return
    end

    if notify
      game.broadcast_flash(alert: "Игра будет скоро завершена")

      self.class.set(wait_until: Time.now + (Game::IDLE_GAME_TIME * 0.25).seconds)
                .perform_later(game_id, last_updated_at, notify: false, force:)
      return
    end

    game.conclude
  end
end
