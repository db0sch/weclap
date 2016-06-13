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

    graph = Koala::Facebook::API.new(user.token)
    f = graph.get_connections("me", "friends")
    friendslist = []
    unless f.blank?
      f.each do |fb_friend|
        friendslist << fb_friend['id'] unless User.find_by_uid(fb_friend["id"]).nil?
        raise
      end
    end
    user.update({friendslist: friendslist.to_json})
  end
end
