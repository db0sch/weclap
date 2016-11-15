class Provider < ApplicationRecord
  has_many :streamings, dependent: :destroy
  has_many :movies, -> { distinct }, through: :streamings
end
