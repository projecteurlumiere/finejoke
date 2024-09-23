class AwardsController < ApplicationController
  before_action :verify_turbo_stream_format

  # =create
  def gift
    @user = User.find(params[:award][:user_id])
    @award = @user.awards.build(award_params)
    authorize @award
    if @award.save
      flash[:notice] = t(:".award_given")
      redirect_to profile_path(@award.user)
    else
      flash.now[:alert] = t(:".award_not_given")
      render_turbo_flash(status: :unprocessable_entity)
    end
  end

  private

  def award_params
    params.require(:award).permit(:present_id, :user_id, :signature)
  end
end
