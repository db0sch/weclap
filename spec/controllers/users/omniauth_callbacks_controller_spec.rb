require 'rails_helper'

RSpec.describe Users::OmniauthCallbacksController, type: :controller do
  describe "GET #wunderlist" do
    it "responds successfully with an HTTP 200 status code" do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      get :wunderlist
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end
  end
end
