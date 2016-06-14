class SearchController < ApplicationController
  skip_after_action :verify_policy_scoped, only: :index

  def index
    search_terms = params[:terms]

    @movies = Movie.which_title_contains(search_terms)
    @friends = current_user.friendslist

    render 'movies/index'
  end
end
