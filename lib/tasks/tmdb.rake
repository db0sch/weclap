namespace :tmdb do
  desc "TODO"
  task seed_db: :environment do
    p ENV['TMDB_API_KEY']
    Tmdb::Api.key(ENV['TMDB_API_KEY'])
    p Tmdb::Movie.find("batman")
  end

end
