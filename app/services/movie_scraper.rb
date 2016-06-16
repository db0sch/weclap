class MovieScraper
  class << self

    def get_movie_list(count, start = 1, desc = false) # Retrieve 50 per request
      p url = "http://www.imdb.com/search/title?title_type=feature&start=#{start}&sort=release_date_us#{desc ? ',desc' : ''}"
      begin
        movies_response = RestClient.get url
        fail unless movies_response.code == 200
      rescue
        puts "Could not retrieve movie listing from IMDb (URL: #{url})"
        return
      end

      movies_html = Nokogiri::HTML(movies_response.body).search('table.results tr.detailed td.title')
      movie_ids = []
      movies_html.take(count).each do |m|
        imdb_id = m.search(".wlb_wrapper").attribute('data-tconst').value
        mv = Movie.unscoped.new({
          imdb_id: imdb_id,
          imdb_score: m.search(".user_rating span.rating-rating > span.value").text.to_f,
          release_date: Date.new(m.search("span.year_type").text.match(/\d+/)[0].to_i, 1, 1)
        })
        mv.save if mv.valid?
        movie_ids << imdb_id
      end
      GetMovieDetailsJob.perform_later(movie_ids) if movie_ids.any?
      movie_ids.count
    end


    def get_movie_details(imdb_id)
      puts "retrieving movie (imdb_id: #{imdb_id}) from tmdb"
#SBE 2do do not call each time
Tmdb::Api.key(ENV['TMDB_API_KEY'])

      tmdb_mv = Tmdb::Find.imdb_id(imdb_id)
      return if tmdb_mv.blank? || (tmdb_mv = tmdb_mv['movie_results']).blank?
      # p tmdb_mv = tmdb_mv['movie_results']
      tmdb_id = tmdb_mv.first['id']

      if mv = get_movie_description_through_api(tmdb_id, imdb_id, 'en')
        collection = mv['belongs_to_collection'] ? { mv['belongs_to_collection']['id'] => mv['belongs_to_collection']['name'] } : nil
        return unless movie = Movie.unscoped.find_by(imdb_id: imdb_id)
        r_date = mv['release_date'].blank? ? movie.release_date : mv['release_date'].to_date

        movie.update({
          title: mv['title'],
          original_title: mv['original_title'],
          tmdb_id: tmdb_id,
          runtime: mv['runtime'],
          tagline: mv['tagline'],
          genres: mv['genres'].map { |genre| genre.values.last },
          poster_url: mv['poster_path'] ? "http://image.tmdb.org/t/p/w500" + mv['poster_path'] : nil,
          adult: mv['adult'],
          overview: mv['overview'],
          popularity: mv['popularity'],
          original_language: mv['original_language'],
          release_date: r_date,
          spoken_languages: mv['spoken_languages'],
          collection: collection,
          credits: { cast: get_cast(mv['id']), crew: get_crew(mv['id']) },
          # Add later
          # trailer_url: "https://www.youtube.com/embed#{get_youtube(mv['original_title'])}?rel=0&amp;showinfo=0",
          website_url: "http://www.imdb.com/title/#{imdb_id}",
          cnc_url: "http://vad.cnc.fr/titles?search=#{mv['original_title'].gsub(" ", "+")}&format=4002",
          setup: true
        }.merge(fields_in_french_for(tmdb_id, imdb_id)))
      end
    end

    def find_showtimes_of_the_day(zip_code, city, movie, limit, no_nearing = false)
      url = "http://www.imdb.com/showtimes/title/#{movie.imdb_id}/FR/#{zip_code}"
      response = RestClient.get url
      return {} unless response.code == 200
      theaters = Nokogiri::HTML(response.body).search(".list_item")
      shows = {}
      # First we go through each theater from IMDB and find or create them
      # We then create an array of [[TheaterInstance, NokogiriData], [TheaterInstance, NokogiriData]]
      theaters_data = theaters.map do |t|
        name = t.search(".fav_box").text.strip
        address = t.search(".address").text.strip.gsub(/\n/, "").gsub(/ +/, " ").gsub(/.{17}$/,"") + ' France'
        [Theater.where(name: name).where(address: address).first_or_create(name: name, address: address), t]
      end

      unless no_nearing
        # Then we fetch the nearest theaters
        nearest_theaters = Theater.near("#{zip_code} #{city}", 50, units: :km)
        # Then we select the nearest theaters that were also found by IMDB
        nearest_data = theaters_data.select do |theater_data|
          record = theater_data[0]
          nearest_theaters.include?(record)
        end

        # If we don't have N theaters yet, we try to take more from IMDB
        # The breaker is ugly as fuck but prevents infinite looping in some cases
        breaker = 0
        while nearest_data.size < limit && breaker <= limit - 1
          theaters_data.each do |theater_data|
            record = theater_data[0]
            nearest_data << theater_data unless nearest_data.include?(record)
          end
          breaker += 1
        end
      else
        nearest_data = theaters_data
      end

      # Then we have this list of nearest theaters and their nokogiri data, we take the first N
      nearest_data.take(limit).each do |data|
        theater = data[0]
        t = data[1]
        Show.where(movie: movie).where(theater: theater).where("created_at < ?", Date.parse('last wednesday')).destroy_all
        shows[theater] = Show.where(movie: movie).where(theater: theater)
        if shows[theater].empty?
          t.search(".showtimes meta").each do |h|
            shows[theater] << Show.create(starts_at: Time.zone.parse(h.attribute('content').value), movie: movie, theater: theater)
          end
        end
      end
      shows
    end

    def find_streamings_for(movie)
      pos = movie.cnc_url =~ /\&format\=/
      movie_url = pos ? movie.cnc_url[0...pos] : movie.cnc_url
      movie_url += '&format=4002'
      begin
        response = RestClient.get(movie_url)
        fail unless response.code == 200
      rescue
        puts "Could not retrieve data from the CNC website"
        return {}
      end

      streamings = {}
      doc = Nokogiri::HTML(response.body)
      doc.search(".film-title-search").each do |element|
        local_url = CGI::escapeHTML(element.attribute('href').value).gsub(/°/, '&deg;')
        title = local_url.match(/\=(.+)/)[0].gsub("_", " ").gsub("=", "")

        url = 'http://vad.cnc.fr/' + local_url.gsub(/(\?.*)/, '')
        begin
          movies_response = RestClient.get url
          fail unless movies_response.code == 200
        rescue
          puts "Could not retrieve '#{title}' data from the CNC website"
          next
        end
        doc_2 = Nokogiri::HTML(movies_response.body)
        doc_2.search(".btn-payment-choice").each do |vod_item|
          vod_provider = vod_item.attribute("onclick").value.match(/(, '.+')(, '.+')(, '.+')(, '.+')/)
          provider = vod_provider[2].gsub(", '", "").gsub(",", "").gsub("'", "")
          type = translate_movie_consumption_into_english(vod_provider[3].gsub(", '", "").gsub(",", "").gsub("'", "").gsub("€", ""))
          price = (vod_item.search(".btn-payment-choice-text-no-bold").text.gsub(" €", "").to_f * 100).round
          provider_link = vod_item.attribute("href").value

          unless provider.include?('SFR')
            prvdr = Provider.where(name: provider).first_or_create(name: provider)
            streamings[prvdr] ||= []
            if (strmng = Streaming.where(movie: movie).where(provider: prvdr).where(consumption: type).first)
              strmng.update(price: price, link: provider_link) if strmng.price != price || strmng.link != provider_link # update
            else
              strmng = Streaming.create(consumption: type, link: provider_link, price: price, movie: movie, provider: prvdr) # create
            end
            streamings[prvdr] << strmng
          end
        end
        break
      end
      streamings
    end

    def scrape_and_persist_movies(url, item_container_string)
      Tmdb::Api.key(ENV['TMDB_API_KEY'])
      #Tmdb::Api.language("fr")
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
        next if film['imdb_id'].blank?
        r_date = film['release_date'].blank? ? movie.release_date : film['release_date'].to_date
        movie = Movie.unscoped.new({
          title: film['title'],
          original_title: film['original_title'],
          runtime: film['runtime'],
          tagline: film['tagline'],
          genres: film['genres'].map { |genre| genre.values.last },
          poster_url: film['poster_path'] ? "http://image.tmdb.org/t/p/w500" + film['poster_path'] : nil,
          imdb_id: film['imdb_id'],
          imdb_score: film['vote_average'],
          tmdb_id: film['id'],
          adult: film['adult'],
          overview: film['overview'],
          popularity: film['popularity'],
          original_language: film['original_language'],
          release_date: r_date,
          spoken_languages: film['spoken_languages'],
          credits: { cast: get_cast(film['id']), crew: get_crew(film['id']) },
          trailer_url: "https://www.youtube.com/embed#{get_youtube(film['title'])}?rel=0&amp;showinfo=0",
          website_url: "http://www.imdb.com/title/#{film['imdb_id']}",
          cnc_url: "http://vad.cnc.fr/titles?search=#{film['title'].gsub(" ", "+")}&format=4002",
          setup: true
        })
        puts "#{'%5i' % count += 1}. #{movie.title} (imdb_id: #{movie.imdb_id})"
        movie.valid? ? movie.save : (puts "---> Not persisted: " + movie.errors.full_messages.to_s)
        sleep 1
      end
    end

    private

    def translate_movie_consumption_into_english(word)
      { 'Louer' => 'Rent', 'Acheter' => 'Purchase', 'abonner' => 'Subscribe'}[word]
    end

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

    def get_cast(movie_id, limit = 10)
      cast = Tmdb::Movie.casts(movie_id)
      cast ||= []
      cast.map { |char| char['name'] }[0...limit]
    end

    def get_crew(movie_id)
      crew = Tmdb::Movie.crew(movie_id)
      crew ||= {}
      p_crew = {}
      crew.each { |member| p_crew.key?(member['job']) ? p_crew[member['job']] << member['name'] : p_crew[member['job']] = [member['name']] }
      p_crew
    end

    def get_genres_for(ids)
      ids.map { |id| @genres[id] }
    end

    def retrieve_all_genres
      p @genres ||= Tmdb::Genre.list['genres'].map(&:values).to_h
    end
public

    def get_movie_description_through_api(tmdb_id, imdb_id, lang)
      # Tmdb::Api.key(ENV['TMDB_API_KEY'])
      # tmdb_mv = Tmdb::Find.imdb_id(imdb_id)['movie_results']
      # return if tmdb_mv.nil?

      # tmdb_mv = Tmdb::Find.imdb_id(imdb_id)
      # return if tmdb_mv.nil?
      # # p tmdb_mv = tmdb_mv['movie_results']
      # tmdb_mv = tmdb_mv.first
      movie_response = RestClient.get "http://api.themoviedb.org/3/movie/#{tmdb_id}?language=#{lang}&api_key=#{ENV['TMDB_API_KEY']}"
      return unless movie_response.code == 200
      mv = JSON.parse(movie_response.body)
    end

    def fields_in_french_for(tmdb_id, imdb_id)
      # if Tmdb::Movie.translations(tmdb_id)['translations'].find{ |t| t['iso_639_1'] == 'fr' } && \
      if mv = get_movie_description_through_api(tmdb_id, imdb_id, 'fr')
        return {
          fr_title: mv['title'],
          fr_tagline: mv['tagline'],
          fr_overview: mv['overview'],
        }
      end
      {}
    end
  end
end
