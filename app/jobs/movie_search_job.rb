class MovieSearchJob < ActiveJob::Base
  queue_as :default

  def perform(*args)
    attributes = args.first
    movie = Movie.which_title_contains(attributes["term"]).first
    p "on passe dans le search"
    p movie
    p attributes
    attributes["movie_id"] = movie.id
    PushWunderlistApiJob.perform_later(attributes)
    # lancer un job ou une simple méthode qui ajoute le film à la watchlist du user.
  end
end
