# check ErrorHandling concern for the actual content
class ErrorsController < ApplicationController
  before_action :skip_authorization
  before_action -> { self.send(:"render_#{action_name}") }

  def not_found; end

  def not_authorized; end

  def unknown_format; end

  def internal_server_error; end

  private 

  def no_authentication_required?
    true
  end
end
