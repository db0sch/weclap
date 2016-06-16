class Movie < ActiveRecord::Base
  include PgSearch

  pg_search_scope :autocomplete_title,
                  against: { fr_title: 'A', original_title: 'B', title: 'C' },
                  ignoring: :accents,
                  using: { tsearch: { prefix: true, any_word: true } },
                  order_within_rank: "movies.imdb_score DESC"

  pg_search_scope :which_title_or_synopsis_contains,
                  against: { fr_title: 'A', original_title: 'B', title: 'C', fr_overview: 'D', overview: 'D', tagline: 'D' },
                  ignoring: :accents,
                  using: {
                            tsearch: { prefix: true },
                            dmetaphone: { only: [:fr_title, :title, :origin_title] }
                         },
                  order_within_rank: "movies.imdb_score DESC"

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
