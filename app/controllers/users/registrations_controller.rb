# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  # before_action :configure_sign_up_params, only: [:create]
  # before_action :configure_account_update_params, only: [:update]

  # GET /resource/sign_up
  # def new
  #   super
  # end

  # POST /resource
  # def create
  #   super
  # end

  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  def update
    skip_authorization
    remove_empty_params(%i[email username])

    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    prev_unconfirmed_email = resource.unconfirmed_email if resource.respond_to?(:unconfirmed_email)

    resource_updated = update_resource(resource, account_update_params)

    yield resource if block_given?
    if resource_updated
      set_flash_message_for_update(resource, prev_unconfirmed_email)
      if sign_in_after_change_password?
        bypass_sign_in resource, scope: resource_name
        turbo_redirect_to profile_path(resource.id)
      else
        turbo_redirect_to new_session_path(resource_name)
      end

    else
      flash.now[:alert] = t(:"devise.registrations.not_updated")
      response.status = :unprocessable_entity
      clean_up_passwords resource
      set_minimum_password_length
      render :edit
    end

    # if resource.update_with_password(devise_parameter_sanitizer.sanitize(:account_update))
    #   # flash[:notice] = "Изменения сохранены"
    #   bypass_sign_in resource, scope: resource_name if sign_in_after_change_password?
    #   turbo_redirect_to edit_self_profile_path
    # else
    #   # flash.now[:alert] = "Изменения не были сохранены"
    #   response.status = :unprocessable_entity
    #   render :edit
    # end 
  end

  # DELETE /resource
  def destroy
    skip_authorization
    if resource.destroy_with_password(params[:user][:current_password])
      flash[:notice] = t(:"devise.registrations.destroyed")
      turbo_redirect_to root_path
    else
      flash.now[:alert] = t(:"devise.registrations.not_destroyed")
      render_turbo_flash(status: :unprocessable_entity)
    end 
  end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_up_params
  #   devise_parameter_sanitizer.permit(:sign_up, keys: [:attribute])
  # end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
  # end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end

  private 

  # array of symbols corresponding to params
  def remove_empty_params(params_arr)
    params_arr.each do |param|
      params[:user].delete(param) if params[:user][param]&.strip == ""
    end
  end
end
