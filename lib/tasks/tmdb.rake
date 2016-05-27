include MovieScraper

BASE_URL = "http://api.themoviedb.org/3/"

namespace :tmdb do
  desc "Get from TMDb the 250 all-times best rated movies"
  task seed_atb_movies: :environment do

    url = BASE_URL + "list/522effe419c2955e9922fcf3?sort_by=popularity.desc&api_key=#{ENV['TMDB_API_KEY']}"
    MovieScraper::scrape_and_persist_movies(url, 'items')
  end

  desc "Get from TMDb the yearly best rated movies for the last X years"
  task :seed_yb_movies, [:years] => :environment do |t, args|
    years = args[:years].to_i
    date = Date.today.year

    date.downto(date - years) do |yr|
      puts "Retrieving up to 20 movies for #{yr}"
      url = BASE_URL + "discover/movie?primary_release_year=#{yr}&sort_by=vote_average.desc&api_key=#{ENV['TMDB_API_KEY']}"
      MovieScraper::scrape_and_persist_movies(url, 'results')
    end
  end

  desc "Get from TMDb the movies released for the last X months"
  task :seed_rf_movies, [:months] => :environment do |t, args|
    months = args[:months].to_i
    date = months.months.ago.to_date

    puts "Retrieving 20 movies released since #{date}"
    url = BASE_URL + "discover/movie?primary_release_date.gte=#{date.to_s}&primary_release_date.lte=#{Date.today.to_s}.desc&api_key=#{ENV['TMDB_API_KEY']}"
    MovieScraper::scrape_and_persist_movies(url, 'results')
  end
end
