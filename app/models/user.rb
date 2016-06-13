class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  has_many :interests, dependent: :destroy
  has_many :movies, through: :interests
  has_many :friends, class_name: 'Friendship', foreign_key: 'friend_id'
  has_many :buddies, class_name: 'Friendship', foreign_key: 'buddy_id'

  geocoded_by :address do |obj,results|
    if geo = results.first
      obj.city    = geo.city
      obj.zip_code = geo.postal_code
    end
  end
  after_validation :geocode, if: :address_changed?

  def self.find_for_facebook_oauth(auth)
    access_token = auth.credentials.token
    # where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
    #   user.provider = auth.provider
    #   user.uid = auth.uid
    #   user.email = auth.info.email
    #   user.access_token = access_token
    #   user.password = Devise.friendly_token[0,20]  # Fake password for validation
    #   user.first_name = auth.info.first_name
    #   user.last_name = auth.info.last_name
    #   user.fullname = auth.info.first_name + " " + auth.info.last_name
    #   user.picture = auth.info.image.gsub("http://", "https://")
    #   user.token = auth.credentials.token
    #   user.token_expiry = Time.at(auth.credentials.expires_at)
    # end
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
end


