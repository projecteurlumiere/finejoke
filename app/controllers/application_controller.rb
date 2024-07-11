class ApplicationController < ActionController::Base
  include Pundit::Authorization
  include ErrorHandling
  include TurboRendering
  
  before_action :store_referrer, :authenticate_user!, if: :new_guest?, unless: :devise_controller?
  before_action :configure_permitted_parameters, if: :devise_controller?
  after_action :verify_authorized, unless: :devise_controller?
  after_action :remove_referrer, unless: %i[devise_controller? new_guest?] 

  def no_authentication_required?
    false
  end

  def pundit_user
    current_or_guest_user
  end

  def guest_user_params
    { username: "Joker" + SecureRandom.hex(10) }
  end

  private

  def store_referrer
    session[:referrer] = request.path
  end

  def after_sign_in_path_for(resource)
    turbo_redirect_to_path(params: { path: session[:referrer]})
  end

  def remove_referrer
    session[:referrer] = nil
  end

  def new_guest?
    return false if current_user || session[:guest_user_id]

    true
  end

  helper_method :new_guest?

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:username])
  end

  # def transfer_guest_to_user
  #   # At this point you have access to:
  #   #   * current_user - the user they've just logged in as
  #   #   * guest_user - the guest user they were previously identified by
  #   # 
  #   # After this block runs, the guest_user will be destroyed!

  #   if current_user.cart
  #     guest_user.cart.line_items.update_all(cart_id: current_user.cart.id)
  #   else
  #     guest_user.cart.update!(user: current_user)
  #   end

  #   # In this example we've moved `LineItem` records from the guest
  #   # user's cart to the logged-in user's cart.
  #   #
  #   # To prevent these being deleted when the guest user & cart are
  #   # destroyed, we need to reload the guest record:
  #   guest_user.reload
  # end

  def skip_destroy_guest_user
    true
  end
end
