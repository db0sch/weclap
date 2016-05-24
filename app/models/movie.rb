class Movie < ActiveRecord::Base
  has_many :interests, dependent: :destroy
  has_many :users, through: :interests

  has_many :shows, dependent: :destroy
  has_many :theaters, through: :shows

  has_many :streamings, dependent: :destroy
  has_many :providers, through: :streamings

  validates :imdb_id, uniqueness: true
end
