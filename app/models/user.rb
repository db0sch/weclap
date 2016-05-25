class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  has_many :interests, dependent: :destroy
  has_many :movies, through: :interests
  has_many :friends, class_name: 'Friendship', foreign_key: 'friend_id'
  has_many :buddies, class_name: 'Friendship', foreign_key: 'buddy_id'

  def self.find_for_facebook_oauth(auth)
    access_token = auth.credentials.token
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.provider = auth.provider
      user.uid = auth.uid
      user.email = auth.info.email
      user.access_token = access_token
      user.password = Devise.friendly_token[0,20]  # Fake password for validation
      user.first_name = auth.info.first_name
      user.last_name = auth.info.last_name
      user.full_name = auth.info.first_name + " " + auth.info.last_name
      user.picture = auth.info.image
      user.token = auth.credentials.token
      user.token_expiry = Time.at(auth.credentials.expires_at)
      data = JSON.parse(RestClient.get "https://graph.facebook.com/#{user.uid}/invitable_friends?limit=5000&access_token=#{user.token}&l")
      friends = []
      data["data"].each do |d|
        friends << d['name']
      end
      friends.each do |f|
        User.all.each do |u|
          if u["first_name"] + " " + u["last_name"] == f
            Friendship.new(u.id, User.find_by_full_name(f))
          end
        end

      user.friends = friends
      end
    end
  end
end
