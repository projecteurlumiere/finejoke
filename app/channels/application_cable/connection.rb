module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_or_guest_user

    def connect
      self.current_or_guest_user = find_user
      if current_or_guest_user.connected?
        @already_connected = true
        # reject_unauthorized_connection
      end 

      current_or_guest_user.toggle!(:connected)
    end

    def disconnect
      current_or_guest_user&.update(subscribed_to_game: false)
      current_or_guest_user&.toggle!(:connected) unless @already_connected
    end

    private

    def find_user
      find_verified_user || find_guest_user || reject_unauthorized_connection
    end

    def find_verified_user
      env["warden"].user
    end

    def find_guest_user
      User.find_by(email: cookies.encrypted["_finejoke_session"]["guest_user_id"])
    end
  end
end
