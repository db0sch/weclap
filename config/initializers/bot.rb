unless Rails.env.production?
  Dir["#{Rails.root}/app/bot/**/*.rb"].each { |file| require file }
end