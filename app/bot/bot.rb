require 'facebook/messenger'


# Below the code that allows the webhook configuration.
Facebook::Messenger.configure do |config|
  puts "trying connection"
  # config.access_token = ENV['FB_ACCESS_TOKEN']
  # config.verify_token = ENV['FB_VERIFY_TOKEN']
  config.access_token = ENV['TESTBOT_FB_ACCESS_TOKEN']
  config.verify_token = ENV['TESTBOT_FB_VERIFY_TOKEN']
end

include Facebook::Messenger

# Method when the server receives a message for user (on Messenger or FB page)
Bot.on :message do |message|
  p message

  # messenger_id is needed for the check_user method, to get the user info from fb api.
  # the check_user method return the User instance if any.
  messenger_id = message.sender['id']
  user = check_user(message, messenger_id)

  puts "Received #{message.text} from #{message.sender}"

  if user.nil? #check if the user is registered on weclap.co
    text = "Please, sign in with Facebook on https://www.weclap.co"
    send_text(message.sender, text)
  elsif message.attachments #check if the message sent by the user is really text only.
    text = "Wow, I'm so sorry. I can understand text only :(."
    send_text(message.sender, text)
  else
    # create a users_movies variable that contains all the movies added by the user.
    users_movies = []
    user.interests.each do |interest|
      users_movies << interest.movie
    end

    case message.text.downcase # this is where the messages are being processed.

    when /hello/i
      say_hello(message.sender, user, message)
    when "yo"
      say_hello(message.sender, user, message)
    when "bonjour"
      say_hello(message.sender, user, message)
    when "hey"
      say_hello(message.sender, user, message)

    when /watchlist/i #should return the watchlist in generic template/card mode (max. 10)
      movie_array = []

      if users_movies.empty? # if he has no movie in his watchlist
        text = "Sorry buddy, your watchlist is empty."
        send_text(message.sender, text)
      else # if he has movies in his watchlist, we can't show more than 10 thanks to FB restrictions on generic template.
        counter = 0
        users_movies.each do |movie| # iterate on the user's movies (films in his watchlist)
          if counter < 10
            movie_array << movie_card(movie, false) # the false argument means we shouldn't ask for "add to watchlist" in the cards.
          end
          counter = counter + 1
        end
      end

      # movie_array has been filled with movie card json, we can send them to the user.
      send_movie_cards(message.sender, movie_array)
      
    when "help"
      # just call the help messages which summarize all possible actions (cf. private methods)
      send_help(message.sender)

    when "list"
      # should return the watchlist in text mode.
      if users_movies.empty?
        text = "Sorry buddy, your watchlist is empty."
        send_text(message.sender, text)
      else
        send_text(message.sender, "Your watchlist:")
        users_movies.each do |movie|
          send_text(message.sender, movie.title)
        end
      end

    else # in this case, the bot will search for the words he received. and try to return movies.

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
            movie_array << movie_card(movie, true)
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

Bot.on :postback do |postback|
# when postback are sent to the server. e.g. when the user click on a button on a card.
  messenger_id = postback.messaging['sender']['id']
  user = check_user(postback, messenger_id)

  payload_hash = JSON.parse(postback.payload)

  case payload_hash.keys.first
  when "movie_id"
    # creates a new interest (with the user, and a specific movie).
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
    send_help(postback.messaging['sender'])
    # text = "To search for a film, just send me the title.\n You can also type these commands:\n- \"Hello\": I'm very polite\n- \"List\": Show your watchlist\n- \"Watchlist\": Show the first 10 movies of your watchlist in cards\n- \"Help\": To list all the commands"
  else
    text = 'Oups, something went wrong.'
  end

  send_text(postback.messaging['sender'], text) if text

end

Bot.on :delivery do |delivery|
  puts "Delivered message(s) #{delivery.ids}"
end

private


def send_text(sender, text) # the method to send some text to messenger
  Bot.deliver(
    recipient: sender,
    message: {
      text: text
    }
  )
end

def send_movie_cards(sender, attachment) # to send some cards (generic template)
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

def send_buttons(sender, text, buttons) # to send buttons with text
  Bot.deliver(
    "recipient": sender,
    "message":{
      "attachment":{
        "type":"template",
        "payload":{
          "template_type":"button",
          "text":text,
          "buttons": buttons
        }
      }
    }
  )
end

def movie_card(movie, to_add) # to create movie cards
  # movie is an instance of Movie.
  # to_add is a boolean whether these films can be added or not to the watchlist
  director = movie.credits['crew']['Director'].join(', ') unless movie.credits['crew'].blank?
  if to_add
    card = {
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
  else
    card = {
              "title":"#{movie.title}",
              "image_url":"#{movie.poster_url}",
              "subtitle":"Directed by " + director,
              "buttons":[
                {
                  "type":"web_url",
                  "url":"https://weclap.co/movies/#{movie.id}",
                  "title":"Details"
                },
              ]
            }
  end
  return card
end 

def say_hello(sender, user, message) # to say hello
  text_1 = "Hello #{user.first_name}"
  text_2 = "You can send me 'help' anytime, and I'll help you to interact with me."
  text_3 = "What do you want to do next?"

  buttons = [
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

  send_text(sender, text_1)
  send_text(sender, text_2)
  send_buttons(sender, text_3, buttons)
end

def send_help(sender) # to send help
  text_1 = "Hey buddy, want to know how I work?"
  text_2 = "- \"Hello\": I'm very polite\n- \"List\": Show your watchlist\n- \"Watchlist\": Show the first 10 movies of your watchlist in cards\n- \"Help\": To list all the commands"
  text_3 = "Looking for a film?\nSend me the title, or just a word, and I'll start searching ;)"
  text_4 = "Just try!"
  send_text(sender, text_1)
  send_text(sender, text_2)
  send_text(sender, text_3)
  send_text(sender, text_4)
end

def check_user(message, messenger_id) # to link the messenger user to the fb user
  # response = RestClient.get "https://graph.facebook.com/v2.6/#{messenger_id}?fields=first_name,last_name,profile_pic&access_token=#{ENV['FB_ACCESS_TOKEN']}"
  response = RestClient.get "https://graph.facebook.com/v2.6/#{messenger_id}?fields=first_name,last_name,profile_pic&access_token=#{ENV['TESTBOT_FB_ACCESS_TOKEN']}"
  repos = JSON.parse(response)
  p repos
  user = User.where(first_name: repos["first_name"]).where(last_name: repos["last_name"]).first
  return user
end
