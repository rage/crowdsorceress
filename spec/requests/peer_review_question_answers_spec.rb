# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'PeerReviewQuestionAnswers', type: :request do
  describe 'GET /peer_review_question_answers' do
    it 'works! (now write some real specs)' do
      get peer_review_question_answers_path
      expect(response).to have_http_status(200)
    end
  end
end
