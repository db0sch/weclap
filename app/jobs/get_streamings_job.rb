class GetStreamingsJob < ActiveJob::Base
  queue_as :default

  def perform(movie_id, user_id)
    movie = Movie.find(movie_id)
    puts "Search available streamings for #{movie.title}"
    streamings = MovieScraper::find_streamings_for(movie)
    rendered_data = StreamingsJobController.new.index(streamings)
    PusherClient.get.trigger('watching_events_channel', 'refresh_streamings', { user_id: user_id,  streamings_html: rendered_data })
  end
end
