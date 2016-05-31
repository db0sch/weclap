class MyMovie
  class << self
    def get_movies
      Tmdb::Api.key(ENV['TMDB_API_KEY'])
      Tmdb::Api.language("fr")
      count = 0

      movies = Tmdb::Movie.popular
      p movies.map{ |movie| [movie.title, Tmdb::Movie.translations(movie.id)] }
      p movies.map(&:title)

      # begin
      #   movies_response = RestClient.get url
      #   fail unless movies_response.code == 200
      # rescue
      #   puts "Could not reach the TMDb API with the URL: #{url}"
      #   return
      # end
      # quote = JSON.parse(movies_response.body)[item_container_string]
      # return unless quote

      # quote.each do |filmid|
      #   movie_response = RestClient.get BASE_URL + "movie/#{filmid['id']}?api_key=#{ENV['TMDB_API_KEY']}"
      #   next unless movie_response.code == 200
      #   film = JSON.parse(movie_response.body)
      #   next if film['imdb_id'].blank?
      #   movie = Movie.new({
      #     title: film['title'],
      #     original_title: film['original_title'],
      #     runtime: film['runtime'],
      #     tagline: film['tagline'],
      #     genres: film['genres'].map { |genre| genre.values.last },
      #     poster_url: film['poster_path'] ? "http://image.tmdb.org/t/p/w500" + film['poster_path'] : nil,
      #     imdb_id: film['imdb_id'],
      #     imdb_score: film['vote_average'],
      #     tmdb_id: film['id'],
      #     adult: film['adult'],
      #     budget: film['budget'],
      #     overview: film['overview'],
      #     popularity: film['popularity'],
      #     original_language: film['original_language'],
      #     poster_path: film['poster_path'],
      #     production_countries: film['production_countries'],
      #     release_date: film['release_date'],
      #     spoken_languages: film['spoken_languages'],
      #     credits: { cast: get_cast(film['id']), crew: get_crew(film['id']) },
      #     trailer_url: "https://www.youtube.com/embed#{get_youtube(film['title'])}?rel=0&amp;showinfo=0",
      #     website_url: "http://www.imdb.com/title/#{film['imdb_id']}",
      #     cnc_url: "http://vad.cnc.fr/titles?search=#{film['title'].gsub(" ", "+")}&format=4002"
      #   })
      #   puts "#{'%5i' % count += 1}. #{movie.title} (imdb_id: #{movie.imdb_id})"
      #   movie.valid? ? movie.save : (puts "---> Not persisted: " + movie.errors.full_messages.to_s)
      #   sleep 1
      # end
    end
  end
end
