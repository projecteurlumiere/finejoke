class ApplicationController < ActionController::Base
  include LocalesHandling
  include GuestsHandling
  include Pundit::Authorization
  include TurboRendering
  include ErrorHandling

  layout "layouts/application"
  
  # guest-related methods are defined in GuestsHandling concern
  before_action :welcome_guest, if: :new_guest?, unless: :guest_welcomed?
  before_action :relog_guest, if: :guest_session_expired?
  before_action :authenticate_user!, unless: %i[no_authentication_required?] 
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_title_key
  after_action :verify_authorized, unless: :devise_controller?
  after_action :remove_referrer, unless: %i[devise_controller? new_guest?]

  private
  
  def pundit_user
    current_or_guest_user
  end

  # overriide this in controller to bypass authentication
  def no_authentication_required?
    devise_controller? || current_user || guest_welcomed?
  end

  def authentication_required_for_ai?
    ENV.fetch("ENABLE_AUTHENTICATION_FOR_AI", "").present?
  end

  # for authentication-related redirection
  def store_referrer
    session[:referrer] = request.path
  end

  def remove_referrer
    session[:referrer] = nil
  end

  def after_sign_in_path_for(_resource)
    if request.formats.include?(:turbo_stream)
      turbo_redirect_to_path(params: { path: session[:referrer]})
    else
      session[:referrer] || root_path
    end
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:username])
    devise_parameter_sanitizer.permit(:account_update, keys: %i[username email show_awards_allowed show_jokes_allowed locale])
  end

  # if translation exists - sets custom title 
  # or fallbacks to the default in ApplicationHelper#set_title
  def set_title_key
    key = :"#{controller_name}.#{action_name}_title"
    @title_key ||= key if I18n.exists?(key)
  end

  def strip_params(uri)
    uri = URI.parse(uri)

    uri.query = nil

    uri.to_s
  end

  helper_method :strip_params

  def replace_query_param(uri, name, value)
    uri = URI.parse(uri)

    # parsing query into hash
    query = Rack::Utils.parse_query(uri.query)

    # Replace the value
    query[name] = value

    uri.query = Rack::Utils.build_query(query)
    uri.to_s
  end

  helper_method :replace_query_param
end
