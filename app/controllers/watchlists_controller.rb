class WatchlistsController < ApplicationController
  def show
    @user = User.find(params[:user_id])
    @watchlist = @user.movies
    authorize @watchlist
  end
end
