class Ban < ApplicationRecord
  belongs_to :game, optional: true
  belongs_to :user

  KICKS_REQUIRED_UNTIL_ENFORCE = 3
  GLOBAL_BAN_THRESHOLD = 3 # you must be banned in n games until it becomes global
  EXPIRATION_PERIOD = 1.day # bans expire at some point

  before_save -> {  
    self.enforced = true if self.n_times_kicked >= KICKS_REQUIRED_UNTIL_ENFORCE
  }, unless: :new_record?

  after_save -> {
    return unless Rails.cache.write("clean_up_expired_bans_scheduled", true, expires_in: EXPIRATION_PERIOD, unless_exist: true)

    ::CleanUpExpiredBansJob.set(wait_until: Time.now + EXPIRATION_PERIOD).perform_later
  }

  def self.issue(user, game)
    params = {
      game_id: game.id,
      user_id: user.id,
      ip: user.current_sign_in_ip
    }

    ban = if params[:ip]
            Ban.where(**params.except(:user_id))
               .or(Ban.where(**params.except(:ip)))
          else 
            Ban.where(**params.except(:ip))
          end.limit(1)[0]


    if ban 
      ban.update(n_times_kicked: ban.n_times_kicked + 1)
    else
      game.bans << Ban.new(**params)
    end
  end

  def self.user_banned_from_joining_games?(user)
    params = { enforced: true, created_at: ((Time.now - EXPIRATION_PERIOD)..Time.now) }

    ban_count = Ban.where(ip: user.current_sign_in_ip, **params)
                   .or(Ban.where(user_id: user.id, **params)).count

    ban_count >= GLOBAL_BAN_THRESHOLD
  end

  def self.user_banned_in_game?(user, game)
    params = { game_id: game.id, enforced: true }

    ban = Ban.where(ip: user.current_sign_in_ip, **params)
             .or(Ban.where(user_id: user.id, **params)).limit(1)

    ban.present?
  end

  def self.clean_up_expired_bans
    Ban.where("created_at < ?", (Time.now - EXPIRATION_PERIOD)).in_batches.destroy_all
  end
end
