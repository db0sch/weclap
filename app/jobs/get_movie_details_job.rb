class GetMovieDetailsJob < ActiveJob::Base
  queue_as :default

  def perform(imdb_ids)
    imdb_id = imdb_ids.shift
    puts "--> GetMovieDetailsJob => processing imdb_id: #{imdb_id}, remaining imdb_ids: #{imdb_ids} <--"
    MovieScraper::get_movie_details(imdb_id) unless Movie.find_by(imdb_id: imdb_id)
    GetMovieDetailsJob.set(wait: 0.3.seconds).perform_later(imdb_ids) if imdb_ids.any?
  end
end
