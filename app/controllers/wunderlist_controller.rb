class WunderlistController < ApplicationController

  # Don't need to authenticate or authorize user
  skip_before_action :authenticate_user!
  skip_after_action :verify_authorized
  # Disable protect_from_forgery (API)
  protect_from_forgery with: :null_session

  # Wunderlist API wrapper (active record style)
  require 'wunderlist'

  # Avoid navbar rendering
  layout 'wunderlist'

  def landing
  end

  def webhook
    render nothing: true, status: 200, content_type: 'json' if params['error']
    # Check the type in another (private) method
    # Check if the user is registered in our database with his Wunderlist id.
    # Load him.
    if params['subject']['type'] == "task"
      case params['operation']
      when "create"
        p "CREATE"
        user = User.find_by uid: params['user_id']
        term = params['after']['title']
        task_id = params['after']['id']
        # Trigger a bg job search the movie title
        MovieSearchJob.perform_later({"term" => term, "user_id" => user.id, "task_id" => task_id})
      when "delete"
        p "DELETE"
        # Trigger a bg job which delete the film in the user watchlist
      when "update"
        p "UPDATE"
        term = params['after']['title']
        # Trigger a bg job search the movie title
        # MovieSearchJob.perform_later(term)
        # if the movie is different, then :
          # Trigger a bg job which adds the movie to the user watchlist
          # Trigger a bg job which sends the movie info to the wunderlist of the user.
        # end
      end
    end

    render nothing: true, status: 200, content_type: 'json'
  end
end
