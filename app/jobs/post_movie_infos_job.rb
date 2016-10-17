# class PostMovieInfosJob < ActiveJob::Base
#   queue_as :default

#   require 'wunderlist'

#   def perform(user_id, movie = {})
#     user = User.find(user_id)
#     wl = wunderlist_instance(user)
#     task = get_task(wl, user)
#   end

#   def get_task(wl, user)
#     task = wl.tasks_by_list_id(user.wl_list_id).last  
#   end

#   def create_comment(task, attrs = {})
#     task.new_comment
#   end

#   def update_note(wl, attrs = {})    
#   end

#   def new_subtask(wl, attrs = {})
#   end

#   def wunderlist_instance(user)
#     Wunderlist::API.new({
#       access_token: user.token,
#       client_id: ENV['WUNDERLIST_ID']
#     })
#   end


# $: << '.'
# load 'wunderlist.rb'
# wl = Wunderlist::API.new({access_token: "e12377f6b519852766b8ba6bca7dd629ddecc6bf0dd3e679b80b4599b16b", client_id: "7bcae47d189f0640df56"})
# list = wl.list_by_id(271497561)
# task = wl.tasks_by_list_id(list.id).last
  
# end