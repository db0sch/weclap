class GetShowtimesJob < ActiveJob::Base
  queue_as :default

  def perform(movie_id, location, user_id)
    movie = Movie.find(movie_id)
    puts "Searching for the shows of #{movie.title} near #{location}"
    @shows = MovieScraper::find_showtimes_of_the_day(location, movie, 4)
    rendered_data = JobController.new.index(@shows)
    PusherClient.get.trigger('showtimes', 'display', { user_id: user_id,  shows_html: rendered_data })
  end
end
