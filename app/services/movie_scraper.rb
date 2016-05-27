# require 'htmlentities'

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

  private

  def translate_movie_consumption_into_english(word)
    { 'Louer' => 'Rent', 'Acheter' => 'Purchase', 'abonner' => 'Subscribe'}[word]
  end

end
