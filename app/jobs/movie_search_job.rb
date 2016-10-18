class MovieSearchJob < ActiveJob::Base
  queue_as :default

  def perform(*args)
    movie = Movie.which_title_contains(args[0]).first
    p "on passe dans le search"
    p movie
    PushWunderlistApiJob.perform_later(movie.id, args[1], args[2])
    # lancer un job ou une simple méthode qui ajoute le film à la watchlist du user.
  end
end
