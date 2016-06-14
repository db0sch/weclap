class Movie < ActiveRecord::Base
  include PgSearch
  pg_search_scope :which_title_contains,
                  against: { title: 'A', original_title: 'B', tagline: 'D', overview: 'C' },
                  ignoring: :accents,
                  using: {
                            tsearch: { prefix: true, any_word: true }#,
                            # dmetaphone: { any_word: true },
                            # trigram: { only: :original_title }
                         }

  has_many :interests, dependent: :destroy
  has_many :users, through: :interests

  has_many :shows, dependent: :destroy
  has_many :theaters, -> { distinct }, through: :shows

  has_many :streamings, dependent: :destroy
  has_many :providers, -> { distinct }, through: :streamings

  has_many :jobs, dependent: :destroy
  has_many :people, through: :jobs
  
  validates :imdb_id, uniqueness: true

  default_scope { where(setup: true) }

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
