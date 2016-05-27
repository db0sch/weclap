class Movie < ActiveRecord::Base
  has_many :interests, dependent: :destroy
  has_many :users, through: :interests

  has_many :shows, dependent: :destroy
  has_many :theaters, through: :shows

  has_many :streamings, dependent: :destroy
  has_many :providers, through: :streamings

  validates :imdb_id, uniqueness: true

  def clap_score
    sum = 0.0
    count = 0
    interests.each do |i|
      if i.rating
        sum += i.rating
        count += 1
      end
    end
    sum / count unless count == 0
  end
end
