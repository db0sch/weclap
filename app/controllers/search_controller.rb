class SearchController < ApplicationController
  skip_after_action :verify_policy_scoped, only: :index
  skip_after_action :verify_authorized, only: :autocomplete

  def index
    search_terms = params[:terms]

    @movies = Movie.which_title_or_synopsis_contains(search_terms)
    # @friends = current_user.friendslist
    @friends = current_user.get_friends_list
    render 'movies/index'
  end

  def autocomplete
    search_terms = params[:query]
    p params
    movies = Movie.autocomplete_title(search_terms)
    render json: movies.map{ |m| "#{m.title}" }.take(20)
  end
end
