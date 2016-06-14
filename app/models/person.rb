class Person < ActiveRecord::Base
  has_many :jobs
  has_many :movies, through: :jobs
end
