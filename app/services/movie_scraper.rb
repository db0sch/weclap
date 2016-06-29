class MovieScraper
  class << self

    def get_movie_list(count, start = 1) # Retrieve 50 per request
      counter = 0
      movie_ids = []
      retried = false

      url = "http://www.imdb.com/search/title?sort=release_date_us#{desc ? ',desc' : ''}&start=#{start}&title_type=feature"
      WebScraper.scrape do |page|
        page.visit url
        while count > 0
          begin
            rows = Nokogiri::HTML(page.html).search('table.results tr.detailed td.title')
            cnt = [rows.count, count].min
            rows.take(cnt).each do |m|
              imdb_id = m.search(".wlb_wrapper").attribute('data-tconst').value
              r_date = m.search("span.year_type").text.match(/\d+/)
              r_date = Date.new(r_date[0].to_i, 1, 1) if r_date
              mv = Movie.unscoped.new({
                imdb_id: imdb_id,
                imdb_score: m.search(".user_rating span.rating-rating > span.value").text.to_f,
                release_date: r_date
              })
              mv.save if mv.valid?
              movie_ids << imdb_id
              puts "Retrieved #{counter += 1} movie ids from IMDb"
            end
            GetMovieDetailsJob.perform_later(movie_ids) if movie_ids.any?
            break if movie_ids.count < cnt || (count -= cnt) == 0

            movie_ids = []
            pgn = page.first('.pagination')
            if pgn
              pgn.find('a:last-child').trigger('click')
              sleep 5
            else
              fail WebScraperException, "Pagination element not found in page"
            end

          rescue Capybara::ElementNotFound
            puts "Could not find the 'Next »' link"
            break

          rescue WebScraperException => e
            puts "#{e.message}#{retried ? '' : '... retrying'}"
            retry unless retried
            retried = true

          rescue => e
            puts "***********"
            puts "Could not retrieve movie listing from IMDb (URL: #{url})"
            puts "Error: #{e.message}"
            puts "***********"
          end

          retried = false
        end
      end
    end

    def get_movie_details(imdb_id)
      #SBE 2do do not call each time
      Tmdb::Api.key(ENV['TMDB_API_KEY'])
      tmdb_mv = Tmdb::Find.imdb_id(imdb_id)

      return if tmdb_mv.blank? || (tmdb_mv = tmdb_mv['movie_results']).blank?
      tmdb_id = tmdb_mv.first['id']

      if mv = get_movie_description_through_api(tmdb_id, 'en')
        puts "Retrieving english description of movie (imdb_id: #{imdb_id}) from tmdb"

        collection = mv['belongs_to_collection'] ? { mv['belongs_to_collection']['id'] => mv['belongs_to_collection']['name'] } : nil
        return unless movie = Movie.unscoped.find_by(imdb_id: imdb_id)
        r_date = mv['release_date'].blank? ? movie.release_date : mv['release_date'].to_date

        movie.update(
        {
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
          website_url: "http://www.imdb.com/title/#{imdb_id}",
          cnc_url: "http://vad.cnc.fr/titles?search=#{mv['original_title'].gsub(" ", "+")}&format=4002",
          setup: true
        }.merge(fields_in_french_for({tmdb_id: tmdb_id, runtime: mv['runtime']})))
        retrieve_credits?(movie)
        puts "#{movie.tmdb_id} - #{movie.title} has been created"
        movie
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

    def move_credits_to_jobs_n_people_add_fr_xlations(max = 0)
      # Find all movies with credits
      movies = max > 0 ? Movie.where.not(credits: nil).take(max) : Movie.where.not(credits: nil)
      movies.each_with_index do |movie, index|
        GetFrenchXlationNCreditsJob.set(wait: index * 1.5.seconds).perform_later(movie.id)
      end
    end

    def fields_in_french_for(args)
      if mv = get_movie_description_through_api(args[:tmdb_id], 'fr')
        return {
          fr_title: mv['title'],
          fr_tagline: mv['tagline'],
          fr_overview: mv['overview'],
          runtime: args[:runtime] || args[:runtime] == 0 ? args[:runtime] : mv['runtime']
        }
      end
      {}
    end

    def retrieve_credits?(movie)
      cast = Tmdb::Movie.casts(movie.tmdb_id)
      get_people_and_jobs(team: cast, movie_id: movie.id, job: 'Actor', max_results: 10) unless cast.blank?
      crew = Tmdb::Movie.crew(movie.tmdb_id)
      get_people_and_jobs(team: crew, movie_id: movie.id) unless crew.blank?
      !(cast.blank? && crew.blank?)
    end

    def retrieve_trailers(count)
      return unless movie = Movie.where(trailer_url: nil).first
      get_movie_trailer(movie)
      GetMovieTrailerFromYoutubeJob.set(wait: 0.5.seconds).perform_later(count) if (count -= 1) > 0
    end

# 2DO: replace by a more appropriate picture
    FALLBACK_TRAILER = "http://placehold.it/477x300"
    def get_movie_trailer(movie)
      url = get_youtube(movie)
      movie.update(trailer_url: url ? "https://www.youtube.com/embed#{url}?rel=0&amp;showinfo=0" : FALLBACK_TRAILER)
    end

    private

    def translate_movie_consumption_into_english(word)
      { 'Louer' => 'Rent', 'Acheter' => 'Purchase', 'abonner' => 'Subscribe'}[word]
    end

    def get_youtube(movie)
      titleplus = movie.original_title.delete(';').gsub("'", ' ').gsub(" ", "+").gsub(/[^[:ascii:]]/, "+")
      year = movie.release_date.year
      url = "https://www.youtube.com/results?search_query=allintitle:+\"#{titleplus}+#{year}\"+trailer"
      puts "@@@> Retrieving trailer for '#{movie.title}' with url = #{url} @ Youtube"
      begin
        response = RestClient.get url
      rescue
        return
      end
      return unless response.code == 200
      children = Nokogiri::HTML(response.body).search(".yt-lockup-title").children
      trailer = children.blank? ? nil : children.attribute('href').value.gsub("watch?v=", "")
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
      crew.each { |member|
        p_crew.key?(member['job']) ? p_crew[member['job']] << member['name'] : p_crew[member['job']] = [member['name']] }
      p_crew
    end

    def get_genres_for(ids)
      ids.map { |id| @genres[id] }
    end

    def retrieve_all_genres
      p @genres ||= Tmdb::Genre.list['genres'].map(&:values).to_h
    end

    # def get_movie_description_through_api(tmdb_id, imdb_id, lang)
    def get_movie_description_through_api(tmdb_id, lang)
      mv = {}
      WebScraper.scrape do |page|
        p url = "http://api.themoviedb.org/3/movie/#{tmdb_id}?language=#{lang}&api_key=#{ENV['TMDB_API_KEY']}"
        page.visit url
        mv = JSON.parse(page.find('body').text)
      end
      mv
    end

    VIP_CREW_MEMBERS = ['Director', 'Producer', 'Author', 'Writer', 'Scenario Writer', 'Screenplay'].freeze

    def get_people_and_jobs(args)
      count = args[:max_results] || 20
      job = args[:job]
      args[:team].each do |member|
        if VIP_CREW_MEMBERS.include?(member['job']) || job
          pe = Person.where(tmdb_id: member['id']).first_or_create(name: member['name'])
          j = Job.new(person_id: pe.id, movie_id: args[:movie_id], title: job ? job : member['job'])
          j.save if j.valid?
          return if (count -= 1) <= 0
        end
      end
    end

    def unfold_names(full_name)
      full_name.scan(/(.*)\s(.*)\z/)
    end
  end
end
