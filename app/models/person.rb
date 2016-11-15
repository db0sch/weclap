class Person < ApplicationRecord
  has_many :jobs
  has_many :movies, through: :jobs
end
