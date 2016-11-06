class MovieSearchJob < ActiveJob::Base
  queue_as :default

  def perform(*args)
    attributes = args.first
    puts "Searching for #{attributes["term"] if attributes["term"]}"
    # Call the PG Search method that will return a movie
    movie = Movie.which_title_contains(attributes["term"]).first
    puts "Holly search engine has found this movie: #{movie.title if movie}"
    attributes["movie_id"] = movie.id
    # Launch the job that will "post" movie info into the wunderlist task
    PushWunderlistApiJob.perform_later(attributes)
  end
end
