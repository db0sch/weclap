class SetupMoviesListJob < ActiveJob::Base
  queue_as :default

  require 'wunderlist'

  def perform(user_id)
    user = User.find(user_id)

    wl = Wunderlist::API.new({
      access_token: user.token,
      client_id: ENV['WUNDERLIST_ID']
    })

    list = wl.new_list("Movies")
    list.save


  end
end
