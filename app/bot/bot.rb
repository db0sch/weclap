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
    Bot.deliver(
      recipient: message.sender,
      message: {
        text: "Please, sign in with Facebook on https://www.weclap.co"
      }
    )

  else

  unless message.attachments.nil?

    Bot.deliver(
      recipient: message.sender,
      message: {
        text: "Wow, I'm so sorry. I can understand text only :(."
      }
    )
  else
    users_movies = []
    unless user.interests.empty?
      user.interests.each do |interest|
        users_movies << interest.movie
      end
    end

    case message.text.downcase
    when /hello/i
      Bot.deliver(
        recipient: message.sender,
        message: {
          text: "Hello #{user.first_name}"
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
                  "title":"Search a film",
                  "payload":{"search":"true"}.to_json
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

#change the url for watch the film
    when /watchlist/i
      movie_array = []
      if user.interests.empty?
        Bot.deliver(
          recipient: message.sender,
          message: {
            text: "Sorry buddy, your watchlist is empty."
          }
        )
      else
        counter = 0
        user.interests.each do |interest|
          if counter < 10
            movie_array << {
              "title":"#{interest.movie.title}",
              "image_url":"#{interest.movie.poster_url}",
              "subtitle":"Directed by...",
              "buttons":[
                {
                  "type":"web_url",
                  "url":"#{interest.movie.website_url}",
                  "title":"Show IMDB"
                },
                {
                  "type":"web_url",
                  "url":"#{interest.movie.website_url}",
                  "title":{"movie_id":"#{movie.id}"}.to_json
                },
              ]
            }
          end
          counter = counter + 1
        end
      end
      Bot.deliver(
          recipient: message.sender,
          # message: {
          #   text: "#{movie.title}"
          # }
            "message":{
              "attachment":{
                "type":"template",
                "payload": {
                  "template_type":"generic",
                  "elements":movie_array
                }
              }
            }
        )
    when "help"
      Bot.deliver(
        recipient: message.sender,
        message: {
          text: "Hey buddy, want to know how I work?"
        }
      )
      Bot.deliver(
        recipient: message.sender,
        message: {
          text: "- \"Hello\": I'm very polite\n- \"List\": Show your watchlist\n- \"Watchlist\": Show the first 10 movies of your watchlist in cards\n- \"Help\": To list all the commands"
        }
      )
      Bot.deliver(
        recipient: message.sender,
        message: {
          text: "Looking for a film?\nSend me the title, or just a word, and I'll start searching ;)"
        }
      )
      Bot.deliver(
        recipient: message.sender,
        message: {
          text: "Just try! B|"
        }
      )

    when "list"
      if user.interests.empty?
        Bot.deliver(
          recipient: message.sender,
          message: {
            text: "Sorry buddy, your watchlist is empty."
          }
        )
      else
        Bot.deliver(
          recipient: message.sender,
          message: {
            text: "Your watchlist:"
          }
        )
        user.interests.each do |interest|
          Bot.deliver(
            recipient: message.sender,
            message: {
              text: "- #{interest.movie.title}"
            }
          )
        end
      end
    else
      movies = Movie.where('title ILIKE ? OR original_title ILIKE ?', "%#{message.text}%", "%#{message.text}%")
      movie_array = []
      if movies.empty?
        Bot.deliver(
          recipient: message.sender,
          message: {
            #text: "hello #{user.first_name}"
            text: "Sorry. No film found for #{message.text}"
          }
        )
      else
        counter = 0
        movies.each do |movie|
          next if users_movies.include?(movie)
          if counter < 10
          movie_array << {
            "title":"#{movie.title}",
            "image_url":"#{movie.poster_url}",
            "subtitle":"Directed by...",
            "buttons":[
              {
                "type":"web_url",
                "url":"#{movie.website_url}",
                "title":"Show IMDB"
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
        Bot.deliver(
          recipient: message.sender,
          message: {
            #text: "hello #{user.first_name}"
            text: "Sorry. No film found. Maybe is it already in your watchlist?"
          }
        )
      else
        Bot.deliver(
          recipient: message.sender,
          # message: {
          #   text: "#{movie.title}"
          # }
            "message":{
              "attachment":{
                "type":"template",
                "payload": {
                  "template_type":"generic",
                  "elements":movie_array
                }
              }
            }
        )
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
  when "search"
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
