class ProfilesController < ApplicationController
  before_action :set_user
  before_action :authorize_user_profile!, except: %i[update]

  def show
    @user = params[:id] ? User.find(params[:id]) : set_user

    @jokes = @user.jokes.page(params[:page]) if @user.show_jokes_allowed?
  end

  def edit
  end

  # creates game
  def update
    authorize_user_profile!

    if @user.update(profile_params)
      flash[:notice] = "Настройки изменены"
      redirect_to profile_path(@user)
    else
      flash[:alert] = "Настройки не были изменены"
      render :edit, status: :unprocessable_entity
    end
  end

  private

  # Only allow a list of trusted parameters through.
  def profile_params
    params.require(:user).permit(:show_jokes_allowed, :show_presents_allowed)
  end

  def set_user
    @user = current_or_guest_user
  end

  def authorize_user_profile!
    authorize @user || User, policy_class: ProfilePolicy
  end
end
