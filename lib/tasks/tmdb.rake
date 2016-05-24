namespace :tmdb do
  desc "TODO"
  task seed_db: :environment do
    p ENV['TMDB_API_KEY']
    Tmdb::Api.key(ENV['TMDB_API_KEY'])

    count = 1
    count += 1
    film = Tmdb::Movie.detail(count)

    p film
    # Tmdb::Movie.casts(550)

    # def find_director(count)
    #   Tmdb::Movie.crew(550).each do |c|
    #     return c['name'] if c['job'].include?("Director") && c['department'].include?("Directing")
    #   end
    # end

    # p find_director(550)




  # create_table "movies", force: :cascade do |t|
  #   t.string   "title"
  #   t.string   "original_title"
  #   t.date     "released_fr"
  #   t.integer  "runtime"
  #   t.string   "tagline"
  #   t.string   "genre"
  #   t.text     "credits"
  #   t.string   "poster_url"
  #   t.string   "trailer_url"
  #   t.string   "website_url"
  #   t.string   "imdb_id"
  #   t.integer  "imdb_score"
  #   t.string   "cnc_url"
  #   t.integer  "tmdb_id"
  #   t.datetime "created_at",           null: false
  #   t.datetime "updated_at",           null: false
  #   t.string   "adult"
  #   t.integer  "budget"
  #   t.string   "genres"
  #   t.text     "overview"
  #   t.float    "popularity"
  #   t.string   "original_language"
  #   t.string   "poster_path"
  #   t.text     "production_countries"
  #   t.string   "release_date"
  #   t.text     "spoken_languages"


    # Movie.new({
    #   title:              film["Fight Club"],
    #   original_title:     film["original_title"],
    #   released_fr:        film["release_date"],
    #   runtime:            film["runtime"],
    #   tagline:            film["tagline"],
    #   summary:            film["overview"],
    #   genre:              film["genres"],
    #   parental_rating:    film["adult"],
    #   credits:            {Tmdb::Movie.crew(count), Tmdb::Movie.casts(count)},
    #   poster_url:         film["poster_path"],
    #   trailer_url:        film["adult"],
    #   website_url:        film["adult"],
    #   imdb_id:            film["adult"],
    #   imdb_score:         film["popularity"],
    #   cnc_url:            film["adult"],
    #   tmdb_id:            film["id"]
    # })

    # Movie.new()
    # t.string   "title"
    # t.string   "original_title"
    # t.date     "released_fr"
    # t.integer  "runtime"
    # t.string   "tagline"
    # t.text     "summary"
    # t.string   "genre"
    # t.integer  "parental_rating"
    # t.text     "credits"
    # t.string   "poster_url"
    # t.string   "trailer_url"
    # t.string   "website_url"
    # t.string   "imdb_id"
    # t.integer  "imdb_score"
    # t.string   "cnc_url"
    # t.integer  "tmdb_id"
    # t.datetime "created_at",      null: false
    # t.datetime "updated_at",      null: false


 # "backdrop_path"=>"/8uO0gUM8aNqYLs1OsTBQiXu0fEv.jpg",
 #  "genres"=>[{"id"=>18, "name"=>"Drama"}],
 #  "homepage"=>"http://www.foxmovies.com/movies/fight-club", "id"=>550, "imdb_id"=>"tt0137523",
 #  "original_language"=>"en", "original_title"=>"Fight Club",
 #  "overview"=>"A ticking-time-bomb insomniac and a slippery soap salesman channel primal male aggression into a shocking new form of therapy. Their concept catches on, with underground \"fight clubs\" forming in every town, until an eccentric gets in the way and ignites an out-of-control spiral toward oblivion.",
 #  "popularity"=>4.517329, "poster_path"=>"/811DjJTon9gD6hZ8nCjSitaIXFQ.jpg",
 #   "production_companies"=>[{"name"=>"Regency Enterprises", "id"=>508},
 #    {"name"=>"Fox 2000 Pictures", "id"=>711}, {"name"=>"Taurus Film", "id"=>20555},
 #    {"name"=>"Linson Films", "id"=>54050}, {"name"=>"Atman Entertainment", "id"=>54051},
 #     {"name"=>"Knickerbocker Films", "id"=>54052}], "
 #     production_countries"=>[{"iso_3166_1"=>"DE", "name"=>"Germany"}, {"iso_3166_1"=>"US", "name"=>"United States of America"}],
 #     "release_date"=>"1999-10-14", "revenue"=>100853753, "runtime"=>139,
 #     "spoken_languages"=>[{"iso_639_1"=>"en", "name"=>"English"}],
 #     "status"=>"Released", "tagline"=>"How much can you know about yourself if you've never been in a fight?",
 #      "title"=>"Fight Club", "video"=>false, "vote_average"=>8.0, "vote_count"=>4808}




{"adult"=>false, "backdrop_path"=>"/8uO0gUM8aNqYLs1OsTBQiXu0fEv.jpg", "belongs_to_collection"=>nil, "budget"=>63000000, "genres"=>[{"id"=>18, "name"=>"Drama"}], "homepage"=>"http://www.foxmovies.com/movies/fight-club", "id"=>550, "imdb_id"=>"tt0137523", "original_language"=>"en", "original_title"=>"Fight Club", "overview"=>"A ticking-time-bomb insomniac and a slippery soap salesman channel primal male aggression into a shocking new form of therapy. Their concept catches on, with underground \"fight clubs\" forming in every town, until an eccentric gets in the way and ignites an out-of-control spiral toward oblivion.", "popularity"=>4.517329, "poster_path"=>"/811DjJTon9gD6hZ8nCjSitaIXFQ.jpg", "production_companies"=>[{"name"=>"Regency Enterprises", "id"=>508}, {"name"=>"Fox 2000 Pictures", "id"=>711}, {"name"=>"Taurus Film", "id"=>20555}, {"name"=>"Linson Films", "id"=>54050}, {"name"=>"Atman Entertainment", "id"=>54051}, {"name"=>"Knickerbocker Films", "id"=>54052}], "production_countries"=>[{"iso_3166_1"=>"DE", "name"=>"Germany"}, {"iso_3166_1"=>"US", "name"=>"United States of America"}], "release_date"=>"1999-10-14", "revenue"=>100853753, "runtime"=>139, "spoken_languages"=>[{"iso_639_1"=>"en", "name"=>"English"}], "status"=>"Released", "tagline"=>"How much can you know about yourself if you've never been in a fight?", "title"=>"Fight Club", "video"=>false, "vote_average"=>8.0, "vote_count"=>4808}
"David Fincher"


  end

end
