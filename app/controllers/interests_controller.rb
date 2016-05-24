class InterestsController < ApplicationController
  before_action :set_movie, only: [:create]
  skip_after_action :verify_policy_scoped, only: :index

  def index
    @user = User.find(params[:user_id])
    @watchlist = @user.movies
  end

  def create
    @interest = Interest.new
    @interest.movie = @movie
    @interest.user = current_user
    authorize @interest     
    # authorize @movie    
    if @interest.save
      redirect_to movie_path(@movie)
    else
      raise
    end
  end

  private
    def set_movie
      @movie = Movie.find(params[:movie_id])
      
    end

end
