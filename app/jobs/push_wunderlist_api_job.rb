class PushWunderlistApiJob < ActiveJob::Base
  queue_as :default

  require 'wunderlist'

  def perform(*args)
    attributes = args.first
    movie = Movie.find(attributes["movie_id"])
    p "ready to push the movie #{movie.title} - id: #{movie.id}"
    user = User.find(attributes["user_id"])

    # Créer instance de Wunderlist
    wl = wunderlist_instance(user)
    # Récupérer la task et la stocker dans une variable
    task = wl.task_by_id(attributes["task_id"])
    # Modifier le titre
    task.title = movie.title
    task.save
    # # Appeler le module emoji avec le genre du film en argument
    # # Créer sous-taches avec cast & crew
    director = movie.jobs.where(title: "Director").first.person.name
    task.new_subtask(title: "directed by: #{director}").save
    cast = movie.jobs.select{ |j| j.title == 'Actor' }.reverse.shift(2).map(&:person).map(&:name)
    cast.each { |actor| task.new_subtask(title: actor).save }
    # Créer une note avec durée, année, genre, et synopsis
    note_content = "Duration: #{movie.runtime if movie.runtime}mn
Genre: #{movie.genres.join(", ") if movie.genres}
Year: #{movie.release_date.year if movie.release_date}
\nSynopsis:
#{movie.overview if movie.overview}"
    task.update_or_create_note(content: note_content).save
  end


  def wunderlist_instance(user)
    Wunderlist::API.new({
      access_token: user.token,
      client_id: ENV['WUNDERLIST_ID']
    })
  end
end
