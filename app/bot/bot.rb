require 'facebook/messenger'

Facebook::Messenger.configure do |config|
  puts "trying connection"
  config.access_token = ENV['FB_ACCESS_TOKEN']
  config.verify_token = ENV['FB_VERIFY_TOKEN']
end

include Facebook::Messenger

Bot.on :message do |message|
  fbid = message.sender['id']
  user = User.where(uid: fbid)
  response = RestClient.get "https://graph.facebook.com/v2.6/10208235975350862?fields=first_name,last_name,profile_pic&access_token=#{ENV['FB_ACCESS_TOKEN']}"
  repos = JSON.parse(response)
  user = User.where(first_name: repos["first_name"]).where(last_name: repos["last_name"]).first
  p user

  puts "Received #{message.text} from #{message.sender}"


  case message.text
  when /hello/i
    Bot.deliver(
      recipient: message.sender,
      message: {
        text: "Hello you"
      }
    )
  when /list/i
    interestslist = user.interests
    interestslist.each do |interest|
      Bot.deliver(
        recipient: message.sender,
        message: {
          #text: "hello #{user.first_name}"
          text: "#{interest.movie.title}"
        }
      )
    end
  when /something humans like/i
    Bot.deliver(
      recipient: message.sender,
      message: {
        text: 'I found something humans seem to like:'
      }
    )

    Bot.deliver(
      recipient: message.sender,
      message: {
        attachment: {
          type: 'image',
          payload: {
            url: 'https://i.imgur.com/iMKrDQc.gif'
          }
        }
      }
    )

    Bot.deliver(
      recipient: message.sender,
      message: {
        attachment: {
          type: 'template',
          payload: {
            template_type: 'button',
            text: 'Did human like it?',
            buttons: [
              { type: 'postback', title: 'Yes', payload: 'HUMAN_LIKED' },
              { type: 'postback', title: 'No', payload: 'HUMAN_DISLIKED' }
            ]
          }
        }
      }
    )
  else
    movies = Movie.where('title ILIKE ? OR original_title ILIKE ?', "%#{message.text}%", "%#{message.text}%")
    movies.each do |movie|
      Bot.deliver(
        recipient: message.sender,
        message: {
          text: "#{movie.title}"
        }
      )
    end
    # Bot.deliver(
    #   recipient: message.sender,
    #   message: {
    #     text: 'You are now marked for extermination.'
    #   }
    # )

    # Bot.deliver(
    #   recipient: message.sender,
    #   message: {
    #     text: 'Have a nice day.'
    #   }
    # )
  end
end

Bot.on :postback do |postback|
  case postback.payload
  when 'HUMAN_LIKED'
    text = 'That makes bot happy!'
  when 'HUMAN_DISLIKED'
    text = 'Oh.'
  end

  Bot.deliver(
    recipient: postback.sender,
    message: {
      text: text
    }
  )
end

Bot.on :delivery do |delivery|
  puts "Delivered message(s) #{delivery.ids}"
end