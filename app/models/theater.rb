class Theater < ActiveRecord::Base
  has_many :shows, dependent: :destroy
  has_many :movies, through: :shows
end
