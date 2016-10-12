class SetupMoviesListJob < ActiveJob::Base
  queue_as :default

  require 'wunderlist'

  def perform(user_id)
    user = User.find(user_id)
    wl = wunderlist_instance(user)

    unless user.wl_list_id
      create_and_save_user_list(wl, user)
      check_or_set_webhook(wl, user)
    else
      unless wl.list_by_id(user.wl_list_id)
        create_and_save_user_list(wl, user)
        check_or_set_webhook(wl, user)
      else
        check_or_set_webhook(wl, user)
      end
    end
  end

  def wunderlist_instance(user)
    Wunderlist::API.new({
      access_token: user.token,
      client_id: ENV['WUNDERLIST_ID']
    })
  end

  def create_and_save_user_list(wl, user)
    create_list(wl)
    user.wl_list_id = list_id(user, wl)
    user.save
  end

  def check_or_set_webhook(wl, user)
    list = wl.list_by_id(user.wl_list_id)
    webhooks = wl.webhooks_by_list_id(list.id)
    if webhooks
      set_webhook(wl, list.id) unless check_webhook?(wl, webhooks)
    end
  end

  private

  def create_list(wunderlist)
    list = wunderlist.new_list("Movies")
    list.save
  end

  def list_id(user, wl)
    list_id = wl.get_list_ids(['Movies']).last
    unless any_tasks?(wl, list_id)
      return list_id
    else
      return nil
    end
    # MIGHT NEED AN IMPROVE
  end

  def any_tasks?(wl, list_id)
    wl.tasks_by_list_id(list_id).any?
  end

  def set_webhook(wl, list_id)
    attrs = {
      url: ENV['WL_WEBHOOK_URL'],
      processor_type:"generic",
      configuration:""
    }
    webhook = wl.new_webhook_by_list_id(list_id, attrs)
    webhook.create
  end

  def check_webhook?(wl, webhooks)
    webhooks.any? { |webhook| webhook.url == ENV['WL_WEBHOOK_URL'] }
  end

end
