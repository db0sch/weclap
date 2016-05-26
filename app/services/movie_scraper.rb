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
end
