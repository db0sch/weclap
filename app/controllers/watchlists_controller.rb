class WatchlistsController < ApplicationController
  def index
    @watchlist = Interest.where(user: params[:user])
  end
end
