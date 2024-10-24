class DestroyIdleGameJob < ApplicationJob
  include Rails.application.routes.url_helpers

  queue_as :default

  # notifies first then reschedules itself with force: true
  def perform(game_id, last_updated_at = nil, notify:, force:)
    game = Game.find_by(id: game_id)
    return unless game

    if !force && game.updated_at.after?(last_updated_at)
      game.schedule_idle_game_destroy(notify: true, force:) if game.waiting? || game.on_halt?
      return
    end

    if notify
      game.broadcast_flash(alert: I18n.t(:"game.will_close_soon", locale: game.locale))
      self.class.set(wait_until: Time.now + (Game::IDLE_GAME_TIME * 0.25).seconds)
                .perform_later(game_id, last_updated_at, notify: false, force:)
      return
    end

    game.destroy
  end
end
