class AwardsController < ApplicationController
  
  # =create
  def gift
    @user = User.find(params[:award][:user_id])
    @award = @user.awards.build(award_params)
    authorize @award
    respond_to do |format|
      if @award.save
        flash[:notice] = t(".award_given")
        format.html { redirect_to profile_path(@award.user) }
      else
        flash[:alert] = t(".award_not_given")
        format.turbo_stream { render_turbo_flash(status: :unprocessable_entity) }
      end
    end
  end

  private

  def award_params
    params.require(:award).permit(:present_id, :user_id, :signature)
  end
end
