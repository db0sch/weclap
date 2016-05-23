class Provider < ActiveRecord::Base
  has_many :streamings, dependent: :destroy
  has_many :movies, through: :streamings
end
