# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PeerReviewsController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/peer_reviews').to route_to('peer_reviews#index')
    end

    it 'routes to #show' do
      expect(get: '/peer_reviews/1').to route_to('peer_reviews#show', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/peer_reviews').to route_to('peer_reviews#create')
    end

    it 'routes to #update via PUT' do
      expect(put: '/peer_reviews/1').to route_to('peer_reviews#update', id: '1')
    end

    it 'routes to #update via PATCH' do
      expect(patch: '/peer_reviews/1').to route_to('peer_reviews#update', id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/peer_reviews/1').to route_to('peer_reviews#destroy', id: '1')
    end
  end
end
