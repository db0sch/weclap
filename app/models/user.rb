class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable, :omniauthable, :omniauth_providers => [:facebook, :wunderlist]

  has_many :interests, dependent: :destroy
  has_many :movies, through: :interests

private
  has_many :friendships, foreign_key: 'friend_id', dependent: :destroy
  has_many :friends, through: :friendships, source: :buddy
  has_many :inverse_friendships, class_name: 'Friendship', foreign_key: 'buddy_id', dependent: :destroy
  has_many :buddies, through: :inverse_friendships, source: :friend

public

  geocoded_by :address do |obj,results|
    if geo = results.first
      obj.city    = geo.city
      obj.zip_code = geo.postal_code
    end
  end
  after_validation :geocode, if: :address_changed?

  def get_friends_list
    friends + buddies
  end

  def add_friend(user)
    Friendship.where('(friend_id = ? AND buddy_id = ?) OR (friend_id = ? AND buddy_id = ?)', user.id, self.id, self.id, user.id)
      .first_or_create(friend_id: user.id, buddy_id: self.id)
  end

  def remove_friend(user)
    fr = Friendship.where('(friend_id = ? AND buddy_id = ?) OR (friend_id = ? AND buddy_id = ?)', user.id, self.id, self.id, user.id).first
    fr.destroy if fr
  end

  def watched_movies_list
    interests.includes(:movie).select{ |int| int.watched_on }.map(&:movie)
  end

  def unwatched_movies_list
    interests.includes(:movie).select{ |int| int.watched_on.nil? }.map(&:movie)
  end

  def common_movies_with(user, status = :unwatched)
    cmovies = case status
      when :unwatched then self.unwatched_movies_list & user.unwatched_movies_list
      when :watched then self.watched_movies_list & user.watched_movies_list
      else self.movies & user.movies
    end
  end

  def has_ever_watched_a_movie?
    Interest.where(user: self).where.not(watched_on: nil).exists?
  end

  def self.find_for_facebook_oauth(auth)
    user_params = {
      provider: auth.provider,
      uid: auth.uid,
      email: auth.info.email,
      password: Devise.friendly_token[0,20],  # Fake password for validation
      first_name: auth.info.first_name,
      last_name: auth.info.last_name,
      fullname: auth.info.first_name + " " + auth.info.last_name,
      picture: auth.info.image,
      token: auth.credentials.token,
      token_expiry: Time.at(auth.credentials.expires_at)
    }
    if User.where(provider: auth.provider, uid: auth.uid).first
      # update
      user = User.where(provider: auth.provider, uid: auth.uid).first
      user.update(user_params)
    else
      # create
      user = User.create(user_params)
    end
    return user
  end

  def self.find_for_wunderlist_oauth(auth)
    user_params = {
      provider: "wunderlist",
      uid: auth.uid,
      email: auth.info.email,
      password: Devise.friendly_token[0,20],
      first_name: auth.info.name.split(/\s/).first,
      last_name: auth.info.name.split(/\s/).last,
      fullname: auth.info.name,
      token: auth.credentials.token
    }
    user = User.where(provider: "wunderlist", uid: auth.uid).first
    if user
      # update
      user.update(user_params)
    else
      # create
      user = User.create(user_params)
    end
    return user
  end
end
