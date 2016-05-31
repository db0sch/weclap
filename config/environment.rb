# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Rails.application.initialize!

DEFAULT_META = YAML.load_file(Rails.root.join('config/meta.yml'))
