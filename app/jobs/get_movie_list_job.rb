class GetMovieListJob < ActiveJob::Base
  queue_as :default

  def perform(count, start, desc)
    puts "**> GetMovieListJob => count: #{count}, start: #{start} <**"
    MovieScraper.get_movie_list(count, start, desc)
  end
end
