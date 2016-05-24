class InterestsController < ApplicationController
  before_action :set_movie, only: [:create]

  def create
    interest = Interest.new
    interest.movie = @movie
    interest.user = current_user
    if interest.save
      redirect_to movie_path(@movie)
    else
      raise
    end
  end

  private
    def set_movie
      @movie = Movie.find(params[:movie_id])
      
    end

end
