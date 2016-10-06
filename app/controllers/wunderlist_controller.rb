class WunderlistController < ApplicationController

  # Don't need to authenticate or authorize user
  skip_before_action :authenticate_user!
  skip_after_action :verify_authorized

  # Avoid navbar & footer rendering
  layout 'wunderlist'

  def landing
  end
end
