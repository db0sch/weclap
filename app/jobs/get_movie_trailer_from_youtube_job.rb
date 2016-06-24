class GetMovieTrailerFromYoutubeJob < ActiveJob::Base
  queue_as :default

  def perform(count)
    MovieScraper::retrieve_trailers(count)
  end
end
