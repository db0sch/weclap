require 'pusher'

class PusherClient
  def self.get
    Pusher.app_id = ENV['pusher_app_id'] # ENV['pusher_app_id']'211696'
    Pusher.key = ENV['pusher_key']
    Pusher.secret = ENV['pusher_secret']
    Pusher.cluster = 'eu'
    Pusher.logger = Rails.logger
    Pusher.encrypted = true
    Pusher
  end
end
