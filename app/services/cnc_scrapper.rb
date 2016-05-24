require 'nokogiri'
require 'open-uri'
require "WEBrick"

# imdb, rotten tomatoes
def search_vod(query)

  url = 'http://vad.cnc.fr/titles?search=' + query.strip.gsub(' ', '+')
  begin
    response = open(url)
    doc = Nokogiri::HTML(response)
    vod_array = []
    regex_array = []

    doc.search(".film-title-search").each do |element|
      link = "http://vad.cnc.fr/" + element.attribute("href").value
      link.force_encoding('binary')
      link = WEBrick::HTTPUtils.escape(link)
      title = element.attribute("href").value.match(/\=(.+)/)[0].gsub("_", " ").gsub("=", "")
      response_2 = open(link)
      doc_2 = Nokogiri::HTML(response_2)
      doc_2.search(".btn-payment-choice").each do |vod_item|
        single_vod = []
        vod_provider = vod_item.attribute("onclick").value.match(/(, '.+')(, '.+')(, '.+')(, '.+')/)
        provider = vod_provider[2].gsub(", '", "").gsub(",", "").gsub("'", "")
        type = vod_provider[3].gsub(", '", "").gsub(",", "").gsub("'", "").gsub("€", "")
        price = vod_item.search(".btn-payment-choice-text-no-bold").text

        provider_link = vod_item.attribute("href").value
          single_vod << title
          single_vod << provider
          single_vod << type
          single_vod << price
          single_vod << provider_link
          single_vod << link
          regex_array << single_vod
          #IF YOU WANT TO USE HASHES INSTEAD OF ARRAYS USE THIS LINE
          # vod_array << {title: title, provider: provider, type: type, price: price, provider_link: provider_link, link: link }
          regex_array.each do |sfr|
            regex_array.delete(sfr) if sfr[1].include?("SFR")
          end
      end
    end
  rescue OpenURI::HTTPError => e
    puts "Error= #{e.message}"
  end
  regex_array
end
