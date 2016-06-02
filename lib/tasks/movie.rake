include ActionView::Helpers::TextHelper

# Rake task to populate the DB and update showtimes for each movie in theaters around Paris 01
namespace :movie do
  namespace :channels do
    namespace :availability do
      desc "Preload both showtimes from imdb and available streamings from cnc for Clap! movies"
      task preload: :environment do
        puts "Retrieving showtimes"
        movies = Movie.where('release_date >= ?', 3.months.ago)
        movies.each_with_index do |movie, index|
          begin
            Show.where(movie: movie).where("created_at < ?", Date.parse('last wednesday')).destroy_all
            MovieScraper::find_showtimes_of_the_day('75001', 'Paris', movie, 1, true) if movie.shows.empty?
            puts '%5i' % "#{index + 1}" + ". #{movie.title} => found #{pluralize(movie.shows.count, 'show')}"
          rescue
            puts '%5i' % "#{index + 1}" + ". An error prevented from retrieving any showtime for #{movie.title}"
          end
        end

        puts "Retrieving streamings"
        movies = Movie.where('release_date <= ?', 3.months.ago)
        movies.each_with_index do |movie, index|
          begin
            Streaming.where(movie: movie).where("updated_at < ?", 5.days.ago).destroy_all
            if movie.streamings.empty? || movie.streamings.last.created_at < Date.tomorrow
              MovieScraper::find_streamings_for(movie)
            end
            puts '%5i' % "#{index + 1}" + ". #{movie.title} => found #{pluralize(movie.streamings.count, 'available streaming')}"
          rescue
            puts '%5i' % "#{index + 1}" + ". An error prevented from retrieving any streamings for #{movie.title}"
          end
        end
      end
    end
  end
end
