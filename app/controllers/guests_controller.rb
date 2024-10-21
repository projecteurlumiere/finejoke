class GuestsController < ApplicationController
  after_action :schedule_clean_up_guests

  def create
    skip_authorization
    raise Pundit::NotAuthorizedError if current_user

    session[:guest_welcomed] = true
    session[:guest_session_deadline] = Time.now + 1.day
    flash[:notice] = t(:".you_are_guest")
    current_or_guest_user.update_tracked_fields!(request)
    redirect_to params[:referrer] == root_path ? games_path : params[:referrer]
  end

  private

  def no_authentication_required?
    true
  end

  def schedule_clean_up_guests
    if Rails.cache.write("clean_up_guests_scheduled", true, expires_in: 1.day, unless_exist: true)
      DestroyOldGuestsJob.set(wait_until:  Time.now + 1.day).perform_later
    end
  end
end
