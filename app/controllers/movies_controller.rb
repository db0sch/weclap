class MoviesController < ApplicationController

  def index
    @movies = policy_scope(Movie)
    title = params[:title]
    @movies = @movies.where('title ILIKE ? OR original_title ILIKE ?', "%#{title}%", "%#{title}%") if title
    @friends = my_friends_finder
    # respond_to do |format|
    #   format.html
    #   format.json
    #   format.js
    # end
  end

  def show
    @movie = Movie.find(params[:id])
    @display_shows = display_shows_tab?(@movie)
    @friends = my_friends_finder
    credits = @movie.credits

    @directors = credits['crew']['Director'].join(', ') unless credits['crew'].blank?
    @actors = credits['cast'].take(5).join(', ')
    @genres = @movie.genres.take(2).join(', ')
    @clap_score = @movie.clap_score
    @location = current_user.zip_code
    @city = current_user.city
    @original_title = @movie.original_title unless @movie.original_title.blank? || @movie.title.casecmp(@movie.original_title) == 0
    # execute in background
# 2do
    @streamings = MovieScraper::find_streamings_for(@movie) || {}
#
    GetShowtimesJob.set(wait: 1.seconds).perform_later(@location, @city, @movie.id, current_user.id)
    @shows = []

    authorize @movie
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

  private

  def display_shows_tab?(movie)
    movie.release_date > 3.months.ago
  end
end
