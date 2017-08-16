require 'rails_helper'

RSpec.describe "users/show", type: :view do
  before(:each) do
    @user = assign(:user, User.create!(
      :email => "Email",
      :first_name => "First Name",
      :last_name => "Last Name",
      :administrator => false,
      :username => "Username"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Email/)
    expect(rendered).to match(/First Name/)
    expect(rendered).to match(/Last Name/)
    expect(rendered).to match(/false/)
    expect(rendered).to match(/Username/)
  end
end
