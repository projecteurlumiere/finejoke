class GuestsController < ApplicationController
  def create
    skip_authorization
    raise Pundit::NotAuthorizedError if current_user

    session[:guest_welcomed] = true
    flash[:notice] = t(:".you_are_guest")
    current_or_guest_user.update_tracked_fields!(request)
    redirect_to params[:referrer] === root_path ? games_path : params[:referrer]
  end

  private

  def no_authentication_required?
    true
  end
end
