$redis = Redis.new

url = ENV["REDISCLOUD_URL"]

if url
  Sidekiq.configure_server do |config|
    config.redis = { url: url }
  end

  Sidekiq.configure_client do |config|
    config.redis = { url: url }
  end
  $redis = Redis.new(:url => url)
end

Add a second line to your Procfile

# Procfile
web: bundle exec puma -C config/puma.rb
worker: bundle exec sidekiq -C config/sidekiq.yml

Heroku Cron jobs

Use the Heroku Scheduler

Happy Asynchronizing!
5
