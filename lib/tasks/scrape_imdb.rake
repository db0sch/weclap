namespace :clap do
  namespace :movies do
    desc 'Massively populate Clap! database with batches of movies'
    task :populate, [:start,:count,:order] => :environment do |t, args|
      args.with_defaults(order: 'asc')
      desc = args[:order] == 'desc'
      start = args[:start].to_i
      count = args[:count].to_i
      puts "Retrieving #{count} movies from ?MDb starting at #{start} in '#{args[:order]}' order"
      # GetMovieListJob.perform_later(count, start, desc)
      MovieScraper.get_movie_list(count, start, desc)
    end

    desc 'Upgrade movies\' description to its latest definition'
    task :upgrade, [:max_count] => :environment do |t, args|
      args.with_defaults(max_count: '0')
      count = args[:max_count].to_i
      MovieScraper::move_credits_to_jobs_n_people_add_fr_xlations(count)
    end

    desc 'Retrieve the trailers from Youtube when available'
    task :trailers, [:max_count] => :environment do |t, args|
      args.with_defaults(max_count: '0')
      count = args[:max_count].to_i
      MovieScraper::retrieve_trailers(count)
    end
  end
end
