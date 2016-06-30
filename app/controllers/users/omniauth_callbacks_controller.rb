class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def facebook
    user = User.find_for_facebook_oauth(request.env['omniauth.auth'])
    if user.persisted?
      sign_in_and_redirect user, event: :authentication
      set_flash_message(:notice, :success, kind: 'Facebook') if is_navigational_format?
    else
      session['devise.facebook_data'] = request.env['omniauth.auth']
      redirect_to new_user_registration_url
    end

    graph = Koala::Facebook::API.new(user.token, ENV['FB_SECRET'])
    f = graph.get_connections("me", "friends")
    friendslist = []
    user_updated_friends = []
    unless f.blank?
      f.each do |fb_friend|
        usr = User.find_by_uid(fb_friend["id"])
        if usr
          friendslist << fb_friend['id']
          user_updated_friends << usr
        end
      end
    end
    user_friends = user.get_friends_list
    delta_friends = user_friends - user_updated_friends
    if delta_friends.any? # user has removed some friends on FB
      delta_friends.each{ |f| user.remove_friend(f) }
    end
    delta_friends = user_updated_friends - user_friends
    if delta_friends.any? # user has added some friends on FB
      delta_friends.each{ |f| user.add_friend(f) }
    end

    user.update({ friendslist: friendslist.to_json })
  end
end
