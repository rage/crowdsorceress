require 'rails_helper'

RSpec.describe "peer_reviews/new", type: :view do
  before(:each) do
    assign(:peer_review, PeerReview.new(
      :user_id => "",
      :exercise_id => "",
      :comment => "MyText"
    ))
  end

  it "renders new peer_review form" do
    render

    assert_select "form[action=?][method=?]", peer_reviews_path, "post" do

      assert_select "input[name=?]", "peer_review[user_id]"

      assert_select "input[name=?]", "peer_review[exercise_id]"

      assert_select "textarea[name=?]", "peer_review[comment]"
    end
  end
end
