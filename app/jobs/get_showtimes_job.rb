class GetShowtimesJob < ApplicationJob
  queue_as :default

  def perform(zip_code, city, movie_id, user_id)
    movie = Movie.find(movie_id)
    puts "Search showtimes for #{movie.title} near: #{zip_code} (#{city})"
    shows = MovieScraper::find_showtimes_of_the_day(zip_code, city, movie, 7)
    rendered_data = ShowtimesJobController.new.index(shows)
    PusherClient.get.trigger('watching_events_channel', 'refresh_showtimes', { user_id: user_id,  shows_html: rendered_data, theaters_json: theater_locations_to_json(shows.keys) })
  end

  private

  def theater_locations_to_json(theaters)
    theaters.map{ |theater| { lat: theater.latitude, lng: theater.longitude } }
  end
end
