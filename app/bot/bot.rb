require 'facebook/messenger'

Facebook::Messenger.configure do |config|
  puts "trying connection"
  config.access_token = ENV['FB_ACCESS_TOKEN']
  config.verify_token = ENV['FB_VERIFY_TOKEN']
end

include Facebook::Messenger

Bot.on :message do |message|
  messenger_id = message.sender['id']
  response = RestClient.get "https://graph.facebook.com/v2.6/#{messenger_id}?fields=first_name,last_name,profile_pic&access_token=#{ENV['FB_ACCESS_TOKEN']}"
  repos = JSON.parse(response)
  user = User.where(first_name: repos["first_name"]).where(last_name: repos["last_name"]).first

  puts "Received #{message.text} from #{message.sender}"


  if user.nil?
    #check if the user is registered on weclap.co
    text = "Please, sign in with Facebook on https://www.weclap.co"
    send_text(message.sender, text)
  elsif message.attachments.any?
    #check if the message sent by the user is really text only.
    text = "Wow, I'm so sorry. I can understand text only :(."
    send_text(message.send, text)
  elsif user.interests.any?
    #check if the user as already added a film in his watchlist.
    users_movies = []
    user.interests.each do |interest|
      # create a users_movies variable that contains all the movies added by the user.
      users_movies << interest.movie
    end

    case message.text.downcase
    when /hello/i
      say_hello(user, message)
    when "yo"
      say_hello(user, message)
    when "bonjour"
      say_hello(user, message)

    when /watchlist/i
      movie_array = []
      if user.interests.empty?
        text = "Sorry buddy, your watchlist is empty."
        send_text(message.sender, text)
      else
        counter = 0
        user.interests.each do |interest|
          if counter < 10
            director = interest.movie.credits['crew']['Director'].join(', ') unless interest.movie.credits['crew'].blank?
            movie_array << {
              "title":"#{interest.movie.title}",
              "image_url":"#{interest.movie.poster_url}",
              "subtitle":"Directed by " + director,
              "buttons":[
                {
                  "type":"web_url",
                  "url":"https://weclap.co/movies/#{interest.movie.id}",
                  "title":"Details"
                },
              ]
            }
          end
          counter = counter + 1
        end
      end
      send_movie_cards(message.sender, movie_array)
      
    when "help"
      text_1 = "Hey buddy, want to know how I work?"
      text_2 = "- \"Hello\": I'm very polite\n- \"List\": Show your watchlist\n- \"Watchlist\": Show the first 10 movies of your watchlist in cards\n- \"Help\": To list all the commands"
      text_3 = "Looking for a film?\nSend me the title, or just a word, and I'll start searching ;)"
      text_4 = "Just try!"
      send_text(message.sender, text_1)
      send_text(message.sender, text_2)
      send_text(message.sender, text_3)
      send_text(message.sender, text_4)

    when "list"
      if user.interests.empty?
        text = "Sorry buddy, your watchlist is empty."
        send_text(message.sender, text)
      else
        send_text(message.sender, "Your watchlist:")
        user.interests.each do |interest|
          send_text(message.sender, interest.movie.title)
        end
      end

    else

      movies = Movie.where('title ILIKE ? OR original_title ILIKE ?', "%#{message.text}%", "%#{message.text}%")
      movie_array = []

      if movies.empty?
        text = "Sorry. No film found for #{message.text}"
        send_text(message.sender, text)

      else
        counter = 0
        movies.each do |movie|
          next if users_movies.include?(movie)
          if counter < 10
            director = movie.credits['crew']['Director'].join(', ') unless movie.credits['crew'].blank?
            movie_array << {
              "title":"#{movie.title}",
              "image_url":"#{movie.poster_url}",
              "subtitle":"Directed by " + director ,
              "buttons":[
                {
                  "type":"web_url",
                  "url":"https://weclap.co/movies/#{movie.id}",
                  "title":"Details"
                },
                {
                  "type":"postback",
                  "title":"Add to watchlist",
                  "payload":{"movie_id":"#{movie.id}"}.to_json
                }
              ]
            }
          counter = counter + 1
          end
        end
      end
      if movie_array.empty?
        text = "Sorry. No film found. Maybe is it already in your watchlist?"
        send_text(message.sender, text)
      else
        send_movie_cards(message.sender, movie_array)
      end
    end
  end
  end
end

Bot.on :postback do |postback|

  messenger_id = postback.messaging['sender']['id']
  recipient_id = postback.messaging['recipient']['id']
  response = RestClient.get "https://graph.facebook.com/v2.6/#{messenger_id}?fields=first_name,last_name,profile_pic&access_token=#{ENV['FB_ACCESS_TOKEN']}"
  repos = JSON.parse(response)
  user = User.where(first_name: repos["first_name"]).where(last_name: repos["last_name"]).first

  payload_hash = JSON.parse(postback.payload)

  case payload_hash.keys.first
  when "movie_id"
    interest = Interest.new
    interest.movie = Movie.find(payload_hash["movie_id"])
    interest.user = user
    if Interest.where(user_id: interest.user.id).where(movie_id: interest.movie.id).any?
      text = "#{interest.movie.title} is already in your watchlist"
    else
      if interest.save
        text = "#{interest.movie.title} has been added to your watchlist"
      else
        text = "Sorry. Something went wrong"
      end
    end
  when "find"
    text = "Send me the film title, or just a word, and I'll start searching. :)"
  when "help"
    text = "To search for a film, just send me the title.\n You can also type these commands:\n- \"Hello\": I'm very polite\n- \"List\": Show your watchlist\n- \"Watchlist\": Show the first 10 movies of your watchlist in cards\n- \"Help\": To list all the commands"
  else
    text = 'Oups, something went wrong.'
  end

  Bot.deliver(
    recipient: postback.messaging['sender'],
    message: {
      text: text
    }
  )
end

Bot.on :delivery do |delivery|
  puts "Delivered message(s) #{delivery.ids}"
end

private

def send_text(sender, text)
  Bot.deliver(
    recipient: sender,
    message: {
      text: text
    }
  )
end

def send_movie_cards(sender, attachment)
  Bot.deliver(
    recipient: sender,
    "message":{
      "attachment":{
        "type":"template",
        "payload": {
          "template_type":"generic",
          "elements":attachment
        }
      }
    }
  )
end

def movie_card(movie)
  card = {
            "title":"#{interest.movie.title}",
            "image_url":"#{interest.movie.poster_url}",
            "subtitle":"Directed by " + director,
            "buttons":[
              {
                "type":"web_url",
                "url":"https://weclap.co/movies/#{interest.movie.id}",
                "title":"Details"
              },
            ]
          }
end

def say_hello(user, message)
  Bot.deliver(
    recipient: message.sender,
    message: {
      text: "Hello #{user.first_name}"
    }
  )
  Bot.deliver(
    recipient: message.sender,
    message: {
      text: "You can send me 'help' anytime, and I'll help you to interact with me."
    }
  )       
  Bot.deliver(
    "recipient": message.sender,
    "message":{
      "attachment":{
        "type":"template",
        "payload":{
          "template_type":"button",
          "text":"What do you want to do next?",
          "buttons":[
            {
              "type":"postback",
              "title":"Find a movie",
              "payload":{"find":"true"}.to_json
            },
            {
              "type":"postback",
              "title":"Help",
              "payload":{"help":"true"}.to_json
            }
          ]
        }
      }
    }
  )
  
end