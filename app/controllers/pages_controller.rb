class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: :home
  skip_after_action :verify_authorized, only: [:home, :howto]

  def home
  end

  def howto
  end

end
