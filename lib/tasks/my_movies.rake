namespace :movies do
  desc "Get popular from TMDb"
  task popular: :environment do
    MyMovie::get_movies
  end
end
