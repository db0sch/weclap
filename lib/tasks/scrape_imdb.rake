namespace :clap do
  namespace :movies do
    desc '2do'
    task :populate, [:start,:count,:order,:page_size] => :environment do |t, args|
      args.with_defaults(page_size: '50', order: 'asc')
      desc = args[:order] == 'desc'
      page_size = args[:page_size].to_i
      start = args[:start].to_i
      count = args[:count].to_i
      pages = count / page_size + (count % page_size > 0 ? 1 : 0)
      puts "start = #{start}, count = #{count}, pages = #{pages}"
      GetMovieListJob.perform_later(page_size, count, start, desc) if pages > 0
    end
  end
end
