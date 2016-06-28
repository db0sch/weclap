class MovieApi
  class << self

    def get_movie_tmdb_id(start, count)
      tmdb_id = start.to_i
      count.times do
        get_movie(tmdb_id)
        tmdb_id += 1
      end
    end

    def get_movie(tmdb_id)
      begin
        tmdb_mv = get_movie_details(tmdb_id, "en")
        if tmdb_mv['status_code'] == 34
          puts "Movie with tmdb id #{tmdb_id} doesn't exist"
          return
        end

        fail if tmdb_mv['status_code'] == 25
        p tmdb_mv['status_code'] if tmdb_mv['status_code']

        puts "Movie #{tmdb_id} found on TMDb. Title: #{tmdb_mv["title"]}"

        collection = tmdb_mv['belongs_to_collection'] ? { tmdb_mv['belongs_to_collection']['id'] => tmdb_mv['belongs_to_collection']['name'] } : nil
        return if movie = Movie.unscoped.find_by(tmdb_id: tmdb_id)
        p "Movie #{tmdb_id} is not in database. Let's create it"
        movie = Movie.create!(
        {
          title: tmdb_mv['title'],
          original_title: tmdb_mv['original_title'],
          tmdb_id: tmdb_id,
          imdb_id: tmdb_mv['imdb_id'],
          runtime: tmdb_mv['runtime'],
          tagline: tmdb_mv['tagline'],
          genres: tmdb_mv['genres'].map { |genre| genre.values.last },
          poster_url: tmdb_mv['poster_path'] ? "http://image.tmdb.org/t/p/w500" + tmdb_mv['poster_path'] : nil,
          adult: tmdb_mv['adult'],
          overview: tmdb_mv['overview'],
          popularity: tmdb_mv['popularity'],
          original_language: tmdb_mv['original_language'],
          release_date: tmdb_mv['release_date'],
          spoken_languages: tmdb_mv['spoken_languages'],
          collection: collection,
          website_url: "http://www.imdb.com/title/#{tmdb_mv['imdb_id']}",
          cnc_url: "http://vad.cnc.fr/titles?search=#{tmdb_mv['original_title'].gsub(" ", "+")}&format=4002",
          setup: true
        }.merge(fields_in_french_for({tmdb_id: tmdb_id, runtime: tmdb_mv['runtime']})))
        retrieve_credits?(movie)
        puts "probleme sur film #{movie.title}" unless movie.valid?
      rescue => e
        puts "***** An error occurred with message #{e.message}: retrying in 1 seconds *****"
        sleep 1
        retry
      end
      puts "#{movie.title} has been created. Thank you."
      movie
    end

    def get_movie_details(tmdb_id, lang)
      Tmdb::Api.key(ENV['TMDB_API_KEY'])
      Tmdb::Api.language(lang)
      tmdb_mv = Tmdb::Movie.detail(tmdb_id)
    end

    def fields_in_french_for(args)
      if mv = get_movie_details(args[:tmdb_id], 'fr')
        return {
          fr_title: mv['title'],
          fr_tagline: mv['tagline'],
          fr_overview: mv['overview'],
          fr_release_date: mv['release_date'],
          runtime: args[:runtime] || args[:runtime] == 0 ? args[:runtime] : mv['runtime']
        }
      end
      {}
    end

    def retrieve_credits?(movie)
      cast = Tmdb::Movie.casts(movie.tmdb_id)
      get_people_and_jobs(team: cast, movie_id: movie.id, job: 'Actor', max_results: 10) unless cast.blank?
      crew = Tmdb::Movie.crew(movie.tmdb_id)
      get_people_and_jobs(team: crew, movie_id: movie.id) unless crew.blank?
      !(cast.blank? && crew.blank?)
    end

    VIP_CREW_MEMBERS = ['Director', 'Producer', 'Author', 'Writer', 'Scenario Writer', 'Screenplay'].freeze

    def get_people_and_jobs(args)
      count = args[:max_results] || 20
      job = args[:job]
      args[:team].each do |member|
        if VIP_CREW_MEMBERS.include?(member['job']) || job
          pe = Person.where(tmdb_id: member['id']).first_or_create(name: member['name'])
          j = Job.new(person_id: pe.id, movie_id: args[:movie_id], title: job ? job : member['job'])
          j.save if j.valid?
          return if (count -= 1) <= 0
        end
      end
    end

  end
end
