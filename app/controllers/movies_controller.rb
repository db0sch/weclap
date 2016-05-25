class MoviesController < ApplicationController

  def index
    @movies = policy_scope(Movie)
    title = params[:title]
    @movies = @movies.where('title ILIKE ? OR original_title ILIKE ?', "%#{title}%", "%#{title}%") if title

    respond_to do |format|
      format.html
      format.json
      format.js
    end
  end

  def show
    @movie = Movie.find(params[:id])
    authorize @movie
    # @rating = @movie.interests.reduce { |sum, i| sum += i.rating } / @movie.interests.count if @movie.interests.any?
    sum = @movie.interests.reduce(0) { |sum, i| sum + i.rating if i.rating }
    @rating = (sum / @movie.interests.count) if sum
    respond_to do |format|
      format.html
      format.json
      format.js
    end
  end
end
