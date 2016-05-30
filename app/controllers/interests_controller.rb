class InterestsController < ApplicationController
  before_action :set_movie, only: [:create]
  before_action :set_interest, only: [:update, :destroy]
  skip_after_action :verify_policy_scoped, only: :index

  def index
    @user = User.find(params[:user_id])
    @watchlist = @user.interests
    @friends = my_friends_finder
  end

  def create
    @friend = User.where(id: my_friends_finder).find(params[:friend_id])

    @interest = Interest.new
    @interest.movie = @movie
    @interest.user = current_user
    authorize @interest

    if @interest.save
      current_user.interests.reload
      @friend.interests.reload

      @commun_movies = []
      @friend.interests.each do |movie|
        if movie.watched_on.nil?
          current_user.interests.each do |cumovie|
            if cumovie.movie_id == movie.movie_id
              @commun_movies << movie.movie_id
            end
          end
        end
      end

      respond_to do |format|
        format.html { redirect_to users_path(current_user) }
        format.js  # <-- will render `app/views/interests/create.js.erb`
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
    @interest.watched_on = Time.zone.now
    @interest.save
  end

  def destroy
    authorize @interest
    @interest_id = @interest.id
    if @interest.destroy
      respond_to do |format|
        format.html { redirect_to watchlist_path(current_user) }
        format.js
      end
    else
      respond_to do |format|
        format.html { render  } # gérer l'erreur.
        format.js
      end
    end
  end

  private

    def set_movie
      @movie = Movie.find(params[:movie_id])
    end

    def set_interest
      @interest = Interest.find(params[:id])
    end

    def my_friends_finder
    friend_ids = []

      if !current_user.buddies.nil?
        current_user.buddies.each do |buddy|
          friend_ids << buddy.friend_id
        end
      end
      if !current_user.friends.nil?
        current_user.friends.each do |buddy|
          friend_ids << buddy.buddy_id
        end
      end
      friend_ids
    end

end
