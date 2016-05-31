require 'pusher'

class PusherClient
  def self.get
    Pusher.app_id = ENV['PUSHER_APP_ID'] # ENV['pusher_app_id']'211696'
    Pusher.key = ENV['PUSHER_KEY']
    Pusher.secret = ENV['PUSHER_SECRET']
    Pusher.cluster = 'eu'
    Pusher.logger = Rails.logger
    Pusher.encrypted = true
    Pusher
  end
end
