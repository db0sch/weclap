class GetMovieDetailsJob < ActiveJob::Base
  queue_as :default

  def perform(imdb_ids)
    imdb_id = imdb_ids.shift
    puts "-->     GetMovieDetailsJob => processing imdb_id: #{imdb_id}"
    begin
      MovieScraper::get_movie_details(imdb_id) unless Movie.find_by(imdb_id: imdb_id)
      puts " GetMovieDetailsJob => imdb_id: #{imdb_id} processed, remaining imdb_ids: #{imdb_ids.count}     <--"
    rescue => err
      delay = 2 + rand(6)
      puts "***** An error occurred with message #{err.message}: retrying in #{delay} seconds *****"
      sleep(delay)
      retry
    end
    GetMovieDetailsJob.set(wait: (((rand(5) == 1) ? 1 : 0) * 2).seconds).perform_later(imdb_ids) if imdb_ids.any?
  end
end
