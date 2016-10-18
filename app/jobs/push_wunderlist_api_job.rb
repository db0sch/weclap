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
    # Récupérer la liste et la stocker dans une variable
    # list = wl.list_by_id(user.wl_list_id)
    # Récupérer la task et la stocker dans une variable
    task = wl.task_by_id(attributes["task_id"])
    p "this is the task we want:"
    p task
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
    # Et envoyer les requêtes à l'API Wunderlist
  end


  def wunderlist_instance(user)
    Wunderlist::API.new({
      access_token: user.token,
      client_id: ENV['WUNDERLIST_ID']
    })
  end
end
