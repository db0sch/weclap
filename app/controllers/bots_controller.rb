class BotsController < ApplicationController
  skip_before_action :authenticate_user!, only: :webhook
  def webhook
     if params[‘hub.verify_token’] == “55d9c7c3cb15caf6e6c07ab217665546ed60967a84e7a267454d6197520db05406ac04b488771f65750ebc686e79e1d3a1473ef2716cf322d512a2d369f01fe6”
       render text: params[‘hub.challenge’] and return
     else
       render text: ‘error’ and return
     end
  end

end
