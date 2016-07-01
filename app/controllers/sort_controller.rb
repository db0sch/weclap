class SortController < ApplicationController
  skip_after_action :verify_policy_scoped, only: :index, unless: :devise_controller?

  def index
    interests = current_user.interests.includes(movie: [{ jobs: :person }]).select{ |int| int.watched_on.nil? }
    @list = case params[:sort].to_i
      when 1 then interests.sort_by{ |interest| interest.movie.imdb_score }.reverse
      when 2 then interests.sort_by{ |interest| interest.movie.release_date }.reverse
      else interests
    end

    respond_to do |format|
      format.js  # <-- will render `app/views/sort/index.js.erb`
    end
  end
end
