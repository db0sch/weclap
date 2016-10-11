class WunderlistController < ApplicationController

  # Don't need to authenticate or authorize user
  skip_before_action :authenticate_user!
  skip_after_action :verify_authorized
  # Disable protect_from_forgery (API)
  protect_from_forgery with: :null_session

  # Wunderlist API wrapper (active record style)
  require 'wunderlist'

  # Avoid navbar rendering
  layout 'wunderlist'

  def landing
  end

  def webhook
    params
  end
end
