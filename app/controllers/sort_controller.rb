class SortController < ApplicationController
  skip_after_action :verify_policy_scoped, only: :index, unless: :devise_controller?

  def index
    @list = []
    if params[:sort].to_i == 1
      @list = current_user.interests.sort_by{|interest| Movie.find(interest.movie_id).imdb_score}.reverse
    elsif params[:sort].to_i == 2
      @list = current_user.interests.sort_by{|interest| Movie.find(interest.movie_id).release_date}.reverse
    else
      @list = current_user.interests
    end
    respond_to do |format|
        # format.html { redirect_to restaurant_path(@restaurant) }
        format.js  # <-- will render `app/views/reviews/create.js.erb`
    end
  end
end
