require 'rails_helper'

RSpec.describe "PeerReviewQuestions", type: :request do
  describe "GET /peer_review_questions" do
    it "works! (now write some real specs)" do
      get peer_review_questions_path
      expect(response).to have_http_status(200)
    end
  end
end
