class Streaming < ActiveRecord::Base
  belongs_to :movie
  belongs_to :provider
end
