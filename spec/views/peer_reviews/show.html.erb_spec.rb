require 'rails_helper'

RSpec.describe "peer_reviews/show", type: :view do
  before(:each) do
    @peer_review = assign(:peer_review, PeerReview.create!(
      :user_id => "",
      :exercise_id => "",
      :comment => "MyText"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(/MyText/)
  end
end
