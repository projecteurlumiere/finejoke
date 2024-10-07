# guest-related callbacks are defined in ApplicationController
module GuestsHandling
  extend ActiveSupport::Concern
  
  included do
    private 

    def relog_guest
      session.delete(:guest_welcomed)
      welcome_guest
    end

    # expiration date is set in guests_controller
    def guest_session_expired?
      session[:guest_user_id] &&
        session[:guest_session_deadline] &&
        session[:guest_session_deadline] < Time.now 
    end

    def guest_welcomed?
      session[:guest_welcomed]
    end

    def new_guest?
      return false if current_user || session[:guest_user_id]

      true
    end

    helper_method :new_guest?

    def welcome_guest
      flash[:notice] = t(:"application.welcome_guest")

      store_referrer unless no_authentication_required?
    end

    def transfer_guest_to_user
      return if (Time.now - User.last.created_at) / 86400 > 1 # should not merge user is at least 1 days old

      ActiveRecord::Base.transaction do
        guest_user.game&.remove_user(guest_user)
        current_user.merge(guest_user)
        guest_user.reload
      end
    end
  end
end