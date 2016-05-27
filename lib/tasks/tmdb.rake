BASE_URL = "http://api.themoviedb.org/3/"

namespace :tmdb do
  desc "Get from TMDb the 250 all-times best rated movies"
  task seed_atb_movies: :environment do

    url = BASE_URL + "list/522effe419c2955e9922fcf3?sort_by=popularity.desc&api_key=#{ENV['TMDB_API_KEY']}"
    scrape_and_persist_movies(url, 'items')
  end

  desc "Get from TMDb the yearly best rated movies for the last X years"
  task :seed_yb_movies, [:years] => :environment do |t, args|
    years = args[:years].to_i
    date = Date.today.year

    date.downto(date - years) do |yr|
      puts "Retrieving up to 20 movies for #{yr}"
      url = BASE_URL + "discover/movie?primary_release_year=#{yr}&sort_by=vote_average.desc&api_key=#{ENV['TMDB_API_KEY']}"
      scrape_and_persist_movies(url, 'results')
    end
  end

  desc "Get from TMDb the movies released for the last X months"
  task :seed_rf_movies, [:months] => :environment do |t, args|
    months = args[:months].to_i
    date = months.months.ago.to_date

    puts "Retrieving 20 movies released since #{date}"
    url = BASE_URL + "discover/movie?primary_release_date.gte=#{date.to_s}&primary_release_date.lte=#{Date.today.to_s}.desc&api_key=#{ENV['TMDB_API_KEY']}"
    scrape_and_persist_movies(url, 'results')
  end
end

private
# Service methods
def get_youtube(title)
  titleplus = title.gsub(" ", "+").gsub(/[^[:ascii:]]/, "+")
  begin
    response = RestClient.get "https://www.youtube.com/results?search_query=#{titleplus}+trailer"
  rescue
    return ''
  end
  return '' unless response.code == 200
  trailer = Nokogiri::HTML(response.body)
    .search(".yt-lockup-title")
    .children
    .attribute('href')
    .value.gsub("watch?v=", "")
  trailer ? trailer : ''
end

def scrape_and_persist_movies(url, item_container_string)
  Tmdb::Api.key(ENV['TMDB_API_KEY'])
  count = 0
  begin
    movies_response = RestClient.get url
    fail unless movies_response.code == 200
  rescue
    puts "Could not reach the TMDb API with the URL: #{url}"
    return
  end
  quote = JSON.parse(movies_response.body)[item_container_string]
  return unless quote
  quote.each do |filmid|
    movie_response = RestClient.get BASE_URL + "movie/#{filmid['id']}?api_key=#{ENV['TMDB_API_KEY']}"
    next unless movie_response.code == 200
    film = JSON.parse(movie_response.body)
    movie = Movie.new({
      title: film['title'],
      original_title: film['original_title'],
      runtime: film['runtime'],
      tagline: film['tagline'],
      genres: film['genres'],
      poster_url: film['poster_path'] ? "http://image.tmdb.org/t/p/w500/" + film['poster_path'] : nil,
      imdb_id: film['imdb_id'],
      imdb_score: film['vote_average'],
      tmdb_id: film['id'],
      adult: film['adult'],
      budget: film['budget'],
      overview: film['overview'],
      popularity: film['popularity'],
      original_language: film['original_language'],
      poster_path: film['poster_url'],
      production_countries: film['production_countries'],
      release_date: film['release_date'],
      spoken_languages: film['spoken_languages'],
      credits: {cast: Tmdb::Movie.casts(film['id']), crew: Tmdb::Movie.crew(film['id'])},
      trailer_url: "https://www.youtube.com/embed#{get_youtube(film['title'])}?rel=0&amp;showinfo=0",
      website_url: "http://www.imdb.com/title/#{film['imdb_id']}",
      cnc_url: "http://vad.cnc.fr/titles?search=#{film['title'].gsub(" ", "+")}&format=4002"
    })
    puts "#{count += 1}. #{movie.title}"
    movie.valid? ? movie.save : (puts "---> Not persisted: " + movie.errors.full_messages.to_s)
    sleep 1
  end
end
