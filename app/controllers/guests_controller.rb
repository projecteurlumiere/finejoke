class GuestsController < ApplicationController
  def create
    skip_authorization
    session[:guest_welcomed] = true
    flash[:notice] = t(:".you_are_guest")
    redirect_to params[:referrer] === root_path ? games_path : params[:referrer]
  end

  private

  def guest_welcomed
    true
  end
end
