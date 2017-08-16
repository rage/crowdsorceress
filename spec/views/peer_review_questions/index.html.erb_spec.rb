require 'rails_helper'

RSpec.describe "peer_review_questions/index", type: :view do
  before(:each) do
    assign(:peer_review_questions, [
      PeerReviewQuestion.create!(
        :question => "Question",
        :exercise_type_id => ""
      ),
      PeerReviewQuestion.create!(
        :question => "Question",
        :exercise_type_id => ""
      )
    ])
  end

  it "renders a list of peer_review_questions" do
    render
    assert_select "tr>td", :text => "Question".to_s, :count => 2
    assert_select "tr>td", :text => "".to_s, :count => 2
  end
end
