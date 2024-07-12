class AwardsController < ApplicationController
  
  # =create
  def gift
    @user = User.find(params[:award][:user_id])
    @award = @user.awards.build(award_params)
    authorize @award
    respond_to do |format|
      if @award.save
        flash[:notice] = "Подарок подарен"
        format.html { redirect_to profile_path(@award.user) }
      else
        flash[:alert] = "Подарок не удалось подарить"
        format.turbo_stream { render_turbo_flash(status: :unprocessable_entity) }
      end
    end
  end

  private

  def award_params
    params.require(:award).permit(:present_id, :user_id, :signature)
  end
end
