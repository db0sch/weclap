class InterestsController < ApplicationController
  before_action :set_movie, only: [:create]
  before_action :set_interest, only: [:update, :destroy]
  skip_after_action :verify_policy_scoped, only: :index

  def index
    @user = User.find(params[:user_id])
    @watchlist = @user.interests
  end

  def create
    @interest = Interest.new
    @interest.movie = @movie
    @interest.user = current_user
    authorize @interest     

    if @interest.save
      respond_to do |format|
        format.html { redirect_to users_path(current_user) }
        format.js  # <-- will render `app/views/reviews/create.js.erb`
      end
    else
      respond_to do |format|
        format.html { render 'movies/index' }
        format.js  # <-- idem
      end
    end    
    # if @interest.save
    #   redirect_to movie_path(@movie)
    # else
    #   raise
    # end
  end

  def update
    authorize @interest
    @interest.rating = params[:rating]
    @interest.watched_on = Time.now
    @interest.save
  end

  def destroy
    
  end

  private
    def set_movie
      @movie = Movie.find(params[:movie_id])
    end

    def set_interest
      @interest = Interest.find(params[:id])
    end

end
