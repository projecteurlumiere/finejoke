class RootController < ApplicationController
  def show
    skip_authorization
  end

  private

  def no_authentication_required?
    false
  end
end
