class CleanUpExpiredBansJob < ApplicationJob
  queue_as :default

  def perform
    Ban.clean_up_expired_bans
  ensure
    Rails.cache.delete("clean_up_expired_bans_scheduled")
  end
end
