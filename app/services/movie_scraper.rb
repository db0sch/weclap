module MovieScraper
  def find_showtimes_of_the_day(zip_code, movie, limit)
    shows = {}
    url = "http://www.imdb.com/showtimes/title/#{movie.imdb_id}/FR/#{zip_code}"
    response = RestClient.get url
    return unless response.code == 200
    theaters = Nokogiri::HTML(response.body).search(".list_item")
    theaters.each_with_index do |t, idx|
      name = t.search(".fav_box").text.strip
      address = t.search(".address").text.strip.gsub(/\n/, "").gsub(/ +/, " ").gsub(/.{17}$/,"")
      theater = Theater.where(name: name).where(address: address).first_or_create(name: name, address: address)
      shows[theater] ||= []
      t.search(".showtimes meta").each do |h|
        shows[theater] << Show.create(starts_at: Time.zone.parse(h.attribute('content').value), movie: movie, theater: theater)
      end
      break if idx >= limit + 1
    end
    shows
  end

  def find_streamings_for(movie)
    pos = movie.cnc_url =~ /\&format\=/
    movie_url = pos ? movie.cnc_url[0...pos] : movie.cnc_url
    movie_url += '&format=4002'
    streamings = {}
    begin
      response = RestClient.get(movie_url)
      fail unless response.code == 200
    rescue
      puts "Could not retrieve data from the CNC website"
      return nil
    end

    doc = Nokogiri::HTML(response.body)
    doc.search(".film-title-search").each do |element|
      local_url = CGI::escapeHTML(element.attribute('href').value).gsub(/°/, '&deg;')
      title = local_url.match(/\=(.+)/)[0].gsub("_", " ").gsub("=", "")
      url = "http://vad.cnc.fr/#{local_url}"
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
            strmng.update(price: price, link: provider_link) # update
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
      movie = Movie.new({
        title: film['title'],
        original_title: film['original_title'],
        runtime: film['runtime'],
        tagline: film['tagline'],
        genres: film['genres'].map { |genre| genre.values.last }.to_s,
        poster_url: film['poster_path'] ? "http://image.tmdb.org/t/p/w500" + film['poster_path'] : nil,
        imdb_id: film['imdb_id'],
        imdb_score: film['vote_average'],
        tmdb_id: film['id'],
        adult: film['adult'],
        budget: film['budget'],
        overview: film['overview'],
        popularity: film['popularity'],
        original_language: film['original_language'],
        poster_path: film['poster_path'],
        production_countries: film['production_countries'],
        release_date: film['release_date'],
        spoken_languages: film['spoken_languages'],
        credits: { cast: get_cast(film['id']), crew: get_crew(film['id']) },
        trailer_url: "https://www.youtube.com/embed#{get_youtube(film['title'])}?rel=0&amp;showinfo=0",
        website_url: "http://www.imdb.com/title/#{film['imdb_id']}",
        cnc_url: "http://vad.cnc.fr/titles?search=#{film['title'].gsub(" ", "+")}&format=4002"
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
    cast.map { |char| char['name'] }[0...limit]
  end

  def get_crew(movie_id)
    crew = Tmdb::Movie.crew(movie_id)
    p_crew = {}
    crew.each { |member| p_crew.key?(member['job']) ? p_crew[member['job']] << member['name'] : p_crew[member['job']] = [member['name']] }
    p_crew
  end

  # def get_genres_for(ids)
  #   ids.map { |id| @genres[id] }
  # end

  # def retrieve_all_genres
  #   @genres ||= Tmdb::Genre.list['genres']
  # end
end
