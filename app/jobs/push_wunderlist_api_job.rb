class PushWunderlistApiJob < ActiveJob::Base
  queue_as :default

  require 'wunderlist'

  def perform(*args)
    movie = Movie.find(args.first)
    p "ready to push the movie #{movie.title} - id: #{movie.id}"
    user = User.find(args.last)

    # Créer instance de Wunderlist
    wl = wunderlist_instance(user)
    # Récupérer la liste et la stocker dans une variable
    list = wl.list_by_id(user.wl_list_id)
    # Récupérer la task et la stocker dans une variable

    # Modifier le titre (avec emoji)
    # Appeler le module emoji avec le genre du film en argument
    # Créer sous-taches avec cast & crew
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
