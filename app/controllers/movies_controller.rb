class MoviesController < ApplicationController
  include MovieScraper

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
    sum = @movie.interests.reduce(0) { |sum, i| sum + i.rating if i.rating }
    @rating = (sum / @movie.interests.count) if sum && @movie.interests.any?
    @location = current_user.address
    @shows = find_showtimes_of_the_day(@location || '75001', @movie, 5)
    @original_title = @movie.original_title unless @movie.original_title.blank? || @movie.title.casecmp(@movie.original_title) == 0
    respond_to do |format|
      format.html
      format.json
      format.js
    end
  end
end
