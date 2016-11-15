class PushWunderlistApiJob < ApplicationJob
  queue_as :default

  require 'wunderlist'
  include Emojigenre

  def perform(*args)
    attributes = args.first
    movie = Movie.find(attributes["movie_id"])
    puts "Ready to push the movie #{movie.title} - id: #{movie.id}"
    user = User.find(attributes["user_id"])

    # Create an instance of Wunderlist
    wl = wunderlist_instance(user)
    # Get the task
    task = wl.task_by_id(attributes["task_id"])
    # Change the title of the task & Call the emoji module with the movie genre
    task.title = "#{emojify_genre(movie.genres.first) if movie.genres} #{movie.title}"
    task.save
    # Create subtasks with cast & crew
    director = movie.jobs.where(title: "Director").first.person.name
    task.new_subtask(title: "directed by: #{director}").save
    cast = movie.jobs.select{ |j| j.title == 'Actor' }.reverse.shift(2).map(&:person).map(&:name)
    cast.each { |actor| task.new_subtask(title: actor).save }
    # Create a note with duration, year, genre and synopsis
    note_content = "Duration: #{movie.runtime if movie.runtime}mn
Genre: #{movie.genres.join(", ") if movie.genres}
Year: #{movie.release_date.year if movie.release_date}
\nSynopsis:
#{movie.overview if movie.overview}
\n
=================
\n
Your initial search was \"#{attributes['term'] if attributes['term']}\""
    task.update_or_create_note(content: note_content).save
  end


  def wunderlist_instance(user)
    Wunderlist::API.new({
      access_token: user.token,
      client_id: ENV['WUNDERLIST_ID']
    })
  end
end
