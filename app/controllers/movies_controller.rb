class MoviesController < ApplicationController

  def index
    title = params[:title]
    @movies = title.nil? ? Movie.all : Movie.where('title LIKE ? OR original_title LIKE ?', "%#{title}%", "%#{title}%")
    respond_to do |format|
      format.html
      format.json
      format.js
    end
  end

  def show
    @movie = Movie.find(params[:id])
    respond_to do |format|
      format.html
      format.json
      format.js
    end
  end
end
