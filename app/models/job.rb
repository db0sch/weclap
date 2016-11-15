class Job < ApplicationRecord
  belongs_to :person
  belongs_to :movie
  validates :title, :uniqueness => { :scope => [:person_id, :movie_id] }
end
