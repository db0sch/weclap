require 'open-uri'
require 'nokogiri'
require 'csv'

def find_showtimes_of_the_day(zip_code, movie)
  shows = []
  theater = Nokogiri::HTML(open("http://www.imdb.com/showtimes/title/#{movie.imdb_id}/FR/#{zip_code}")).search(".list_item")
  theater.each do |t|
    name = t.search(".fav_box").text.strip
    address = t.search(".address").text.strip.gsub(/\n/, "").gsub(/ +/, " ").gsub(/.{17}$/,"")
    theater = Theater.where(name: name).where(address: address).first_or_create(name: name, address: address)
    t.search(".showtimes meta").each do |h|
      shows << Show.create(starts_at: Time.parse(h.attribute('content').value), movie: movie, theater: theater)
    end
  end
  shows
end
