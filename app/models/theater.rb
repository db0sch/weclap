class Theater < ApplicationRecord
  has_many :shows, dependent: :destroy
  has_many :movies, -> { distinct }, through: :shows

  geocoded_by :address
  after_validation :geocode, if: :address_changed?
end
