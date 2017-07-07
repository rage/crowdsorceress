# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'PeerReviews', type: :request do
  describe 'GET /peer_reviews' do
    it 'works! (now write some real specs)' do
      get peer_reviews_path
      expect(response).to have_http_status(200)
    end
  end
end
