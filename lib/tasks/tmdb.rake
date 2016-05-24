
require 'open-uri'
require 'nokogiri'
require 'csv'

namespace :tmdb do
  desc "TODO"
  task seed_db: :environment do
    Tmdb::Api.key(ENV['TMDB_API_KEY'])
    count = 1
    p Tmdb::Movie.popular.count
    fargo = Tmdb::Movie.crew(275)
    p fargo
    Tmdb::Movie.popular.each do |popular|

      def get_youtube(title)
        titleplus = title.gsub(" ", "+")
        trailer = Nokogiri::HTML(open("https://www.youtube.com/results?search_query=#{titleplus}+trailer")).search(".yt-lockup-title").children.attribute('href').value.gsub("watch?v=","")
        if !trailer.nil?
          return trailer
        else
          return ''
        end
      end

      count += 1
      film = Tmdb::Movie.detail(popular.id)

      movie = Movie.new({
        title: film['title'],
        original_title: film['original_title'],
        runtime: film['runtime'],
        tagline: film['tagline'],
        genres: film['genres'],
        poster_url: film['poster_url'],
        imdb_id: film['imdb_id'],
        imdb_score: film['imdb_score'],
        tmdb_id: film['tmdb_id'],
        adult: film['adult'],
        budget: film['budget'],
        overview: film['overview'],
        popularity: film['popularity'],
        original_language: film['original_language'],
        poster_path: film['poster_url'],
        production_countries: film['production_countries'],
        release_date: film['release_date'],
        spoken_languages: film['spoken_languages'],
        credits: {cast: Tmdb::Movie.casts(popular.id), crew: Tmdb::Movie.crew(popular.id)},
        trailer_url: "https://www.youtube.com/embed/#{get_youtube(film['title'])}",
        website_url: "http://www.imdb.com/title/#{film['imdb_id']}",
        cnc_url: "http://vad.cnc.fr/titles?search=#{film['title'].gsub(" ", "+")}&format="
        })
      movie.save
      sleep 5
      p movie.title
    end
  end

end
