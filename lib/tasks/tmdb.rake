# url = "/discover/movie?primary_release_year=2010&sort_by=vote_average.desc"

namespace :tmdb do
  desc "Get the 250 all-times best rated movies from IMDb"
  task seed_db: :environment do
    Tmdb::Api.key(ENV['TMDB_API_KEY'])

    def get_youtube(title)
      titleplus = title.gsub(" ", "+").gsub(/[^[:ascii:]]/, "+")
      response = RestClient.get "https://www.youtube.com/results?search_query=#{titleplus}+trailer"
      return '' unless response.code == 200
      trailer = Nokogiri::HTML(response.body)
        .search(".yt-lockup-title")
        .children
        .attribute('href')
        .value.gsub("watch?v=", "")
      trailer ? trailer : ''
    end

    def scrape_and_persist_movies(url)
      count = 0
      movies_response = RestClient.get url
      return 'Cannot reach properly the TMDb api' unless movies_response.code == 200
      # open(api_url) do |stream|
      #   quote = JSON.parse(stream.read)
      quote = JSON.parse(movies_response.body)
      quote['items'].each do |filmid|
        movie_response = RestClient.get "https://api.themoviedb.org/3/movie/#{filmid['id']}?api_key=#{ENV['TMDB_API_KEY']}"
        continue unless movie_response.code == 200
        film = JSON.parse(movie_response.body)
        movie = Movie.new({
          title: film['title'],
          original_title: film['original_title'],
          runtime: film['runtime'],
          tagline: film['tagline'],
          genres: film['genres'],
          poster_url: "http://image.tmdb.org/t/p/w500/" + film['poster_path'],
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
          cnc_url: "http://vad.cnc.fr/titles?search=#{film['title'].gsub(" ", "+")}&format="
        })
        puts "#{count += 1}. #{movie.title}"
        movie.valid? ? movie.save : (puts "---> Error: " + movie.errors.full_messages.to_s)
        sleep 1
      end
    end

    best_rated_movies_url = "http://api.themoviedb.org/3/list/522effe419c2955e9922fcf3?sort_by=popularity.desc&api_key=#{ENV['TMDB_API_KEY']}"
    scrape_and_persist_movies(best_rated_movies_url)
  end
end
