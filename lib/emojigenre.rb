module Emojigenre
  EMOJIS = {
  "Action"=>["👊", "💪", "💥"],
  "Adventure"=>["🎒", "🗺"],
  "Animation"=>["✍", "👾", "👻"],
  "Comedy"=>["😂", "😄"],
  "Crime"=>["🕵", "🔪", "🔫"],
  "Documentary"=>["📹", "🌍", "🌎", "🌏"],
  "Drama"=>["😢", "😿"],
  "Family"=>["👨‍👩‍👧‍👦"],
  "Fantasy"=>["⚔", "🐲"],
  "History"=>["📚", "🏛"],
  "Horror"=>["😱", "😰", "😨", "🎃"],
  "Music"=>["🎙", "🎷", "💃"],
  "Mystery"=>["🔑", "🙃", "❓", "🔍"],
  "Romance"=>["💏", "😍", "😘", "💑"],
  "Science Fiction"=>["🤖", "🚀"],
  "TV Movie"=>["📺"],
  "Thriller"=>["🔪", "😳", "👮", "🔦"],
  "War"=>["🔫", "💣", "💥"],
  "Western"=>["🌵", "🏜"]}

  def emojify_genre(genre)
    EMOJIS[genre].sample
  end
end
