# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PeerReviewQuestionsController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/peer_review_questions').to route_to('peer_review_questions#index')
    end

    it 'routes to #show' do
      expect(get: '/peer_review_questions/1').to route_to('peer_review_questions#show', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/peer_review_questions').to route_to('peer_review_questions#create')
    end

    it 'routes to #update via PUT' do
      expect(put: '/peer_review_questions/1').to route_to('peer_review_questions#update', id: '1')
    end

    it 'routes to #update via PATCH' do
      expect(patch: '/peer_review_questions/1').to route_to('peer_review_questions#update', id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/peer_review_questions/1').to route_to('peer_review_questions#destroy', id: '1')
    end
  end
end
