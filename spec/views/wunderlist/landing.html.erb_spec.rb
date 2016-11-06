require 'rails_helper'

RSpec.describe "wunderlist/landing", type: :view do
  it "renders Connect with Wunderlist" do
    render
    expect(rendered).to include("Connect to Wunderlist")
  end

  it "renders a button to connect to wunderlist" do
    render
    expect(rendered).to have_css("#wunderlist-btn > a", text: "Connect to Wunderlist")
  end



end
