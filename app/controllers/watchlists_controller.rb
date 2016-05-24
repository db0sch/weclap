class WatchlistsController < ApplicationController
  def index
    @user = User.find(params[:user_id])
    @watchlist = @user.movies
  end
end
