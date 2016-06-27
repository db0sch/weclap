class UsersController < ApplicationController
  before_action :set_user, only: [:show, :update]

  def show
    authorize @user
  end

  def update
    authorize @user
    if @user.update(user_params)
      respond_to do |format|
        format.html { redirect_to profile_path }
        format.js  # <-- will render `app/views/users/update.js.erb`
      end
    else
      respond_to do |format|
        format.html { render 'users/show' }
        format.js  # <-- idem
      end
    end
  end

  private

  def set_user
    @user = current_user
  end

  def user_params
    params.require(:user).permit(:newsletter, :secondary_email)
  end
end

