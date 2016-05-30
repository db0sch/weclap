class MoviesController < ApplicationController

  def index
    @movies = policy_scope(Movie)
    title = params[:title]
    @movies = @movies.where('title ILIKE ? OR original_title ILIKE ?', "%#{title}%", "%#{title}%") if title
    @friends = my_friends_finder
    respond_to do |format|
      format.html
      format.json
      format.js
    end
  end

  def show
    @movie = Movie.find(params[:id])
    @friends = my_friends_finder
    credits = @movie.credits

    @directors = credits['crew']['Director'].join(', ') unless credits['crew'].blank?
    @actors = credits['cast'].join(', ')
    @genres = @movie.genres.join(', ')
    @clap_score = @movie.clap_score
    @location = current_user.zip_code
    @city = current_user.city
    @shows = MovieScraper::find_showtimes_of_the_day(@location, @city, @movie, 5)
    @streamings = MovieScraper::find_streamings_for(@movie) || {}
    @original_title = @movie.original_title unless @movie.original_title.blank? || @movie.title.casecmp(@movie.original_title) == 0

    authorize @movie

    respond_to do |format|
      format.html
      format.json
      format.js
    end
  end

  def my_friends_finder
    friend_ids = []

    if !current_user.buddies.nil?
      current_user.buddies.each do |buddy|
        friend_ids << buddy.friend_id
      end
    end
    if !current_user.friends.nil?
      current_user.friends.each do |buddy|
        friend_ids << buddy.buddy_id
      end
    end
    friend_ids
  end
end
