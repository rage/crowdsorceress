require 'rails_helper'

RSpec.describe "peer_review_questions/show", type: :view do
  before(:each) do
    @peer_review_question = assign(:peer_review_question, PeerReviewQuestion.create!(
      :question => "Question",
      :exercise_type_id => ""
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Question/)
    expect(rendered).to match(//)
  end
end
