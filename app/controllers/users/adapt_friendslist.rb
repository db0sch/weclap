
User.all.each do |user|
  uid_friendslist = []
  unless user.friendslist.empty?
    user.friendslist.each do |friend_fullname|
      our_user = User.find_by_fullname(friend_fullname)
      if our_user
        uid_friendslist << our_user.uid
      end
    end
    user.update({friendslist: uid_friendslist.to_json})
  end
end

