class GetMovieListJob < ActiveJob::Base
  queue_as :default

  def perform(page_size, count, start, desc)
    puts "**> GetMovieListJob => page_size: #{page_size}, count: #{count}, start: #{start} <**"
    cnt = [count, page_size].min
    if MovieScraper::get_movie_list(cnt, start, desc) == cnt && count > cnt
      GetMovieListJob.set(wait: 30.seconds).perform_later(page_size, count - cnt, start + cnt, desc)
    end
  end
end
