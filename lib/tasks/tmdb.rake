
require 'open-uri'
require 'nokogiri'
require 'csv'

namespace :tmdb do
  desc "TODO"
  task seed_db: :environment do
    Tmdb::Api.key(ENV['TMDB_API_KEY'])
    count = 1

    def get_youtube(title)
      titleplus = title.gsub(" ", "+")
      trailer = Nokogiri::HTML(open("https://www.youtube.com/results?search_query=#{titleplus}+trailer")).search(".yt-lockup-title").children.attribute('href').value.gsub("watch?v=","")
      if !trailer.nil?
        return trailer
      else
        return ''
      end
    end
    api_url = "http://api.themoviedb.org/3/list/522effe419c2955e9922fcf3?sort_by=popularity.desc&api_key=#{ENV['TMDB_API_KEY']}"

    open(api_url) do |stream|
      quote = JSON.parse(stream.read)
      quote['items'].first(20).each do |film|
        movie = Movie.new({
        title: film['title'],
        original_title: film['original_title'],
        runtime: film['runtime'],
        tagline: film['tagline'],
        genres: film['genres'],
        poster_url: film['poster_path'],
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
        credits: {cast: Tmdb::Movie.casts(film['id']), crew: Tmdb::Movie.crew(film['id'])},
        trailer_url: "https://www.youtube.com/embed#{get_youtube(film['title'])}",
        website_url: "http://www.imdb.com/title/#{film['imdb_id']}",
        cnc_url: "http://vad.cnc.fr/titles?search=#{film['title'].gsub(" ", "+")}&format="
        })
        movie.valid?
        p movie.errors.full_messages
        movie.save
        sleep 5
        p movie.title
    end





    # Tmdb::Movie.popular.each do |popular|



    #   count += 1
    #   film = Tmdb::Movie.detail(popular.id)


     end
  end

end
