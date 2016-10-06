class WunderlistController < ApplicationController

  # Don't need to authenticate or authorize user
  skip_before_action :authenticate_user!
  skip_after_action :verify_authorized

  def landing
  end
end
