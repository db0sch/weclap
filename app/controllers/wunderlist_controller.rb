class WunderlistController < ApplicationController

  # Don't need to authenticate or authorize user
  skip_before_action :authenticate_user!
  skip_after_action :verify_authorized

  # Avoid navbar rendering
  layout 'wunderlist'

  def landing
  end

  def webhook
    p request
    # request.headers['Content-Type'] == 'application/json' ? @data = JSON.parse(request.body.read) : @data = params.as_json
    # render nothing: true, status: 200 if @data == {}
  end
end
