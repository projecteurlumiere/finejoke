class DestroyOldGuestsJob < ApplicationJob
  queue_as :default

  # notifies first then reschedules itself with force: true
  def perform
    deadline = DateTime.now - User::INACTIVE_PERIOD_BEFORE_DESTROY_GUEST
    
    User.joins("LEFT OUTER JOIN rounds ON rounds.user_id = users.id")
        .joins("LEFT OUTER JOIN games ON games.host_id = users.id")
        .where("rounds.user_id is NULL")
        .where("games.host_id is NULL")
        .where("users.game_id is NULL")
        .where("users.updated_at < ?", deadline)
        .in_batches
        .destroy_all

    if User.where(guest: true)
           .where("users.updated_at < ?", deadline)
           .any?
      logger.warn "There are undeleted old guests"
    end
  end
end
