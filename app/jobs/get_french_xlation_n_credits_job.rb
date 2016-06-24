class GetFrenchXlationNCreditsJob < ActiveJob::Base
  queue_as :default

  def perform(movie_id)
    if movie = Movie.find(movie_id)
      Tmdb::Api.key(ENV['TMDB_API_KEY'])
      # Get the french titles and synopsis if available
      movie.update(MovieScraper::fields_in_french_for({ tmdb_id: movie.tmdb_id, runtime: movie.runtime }))
      # Retrieve the movie credits as jobs and
      # Remove the credits so that they are never processed again
      movie.credits = nil if MovieScraper::retrieve_credits?(movie)
      movie.save
    end
  end
end
