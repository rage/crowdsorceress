# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V0::PeerReviewsController, type: :request do
  let(:user) { FactoryGirl.create(:user) }
  before { allow_any_instance_of(Api::V0::PeerReviewsController).to receive(:current_user).and_return(user) }
  let(:exercise) { FactoryGirl.create(:exercise, user: user) }
  let(:another_exercise) { FactoryGirl.create(:exercise, user: user) }

  it 'is created correctly' do
    expect { post_create(exercise) }.to change { PeerReview.count }.by(1)
  end

  it 'is not created without a related exercise' do
    answers = { 'Tehtävän mielekkyys': 5 }
    post '/api/v0/peer_reviews', params: { exercise: { asd: 'asd' }, peer_review: { comment: 'Hyvin menee', answers: answers } }
    expect(response.status).to eq(400)
  end

  it 'also creates tags in case exercise did not have them' do
    expect { post_create(exercise) }.to change { Tag.count }.by(1)
  end

  it 'is not created without a comment or answer' do
    post '/api/v0/peer_reviews', params: { peer_review: { asd: 'asd' }, exercise: { exercise_id: exercise.id, tags: ['asd'] } }
    expect(response.status).to eq(422)
  end

  context 'when submitting again for same exercise' do
    it 'updates the old review' do
      post_create(exercise)
      expect { post_create(exercise) }.to change { PeerReview.count }.by(0)
    end
  end

  context 'when submitting for a different exercise' do
    it 'creates a new peer review answer' do
      post_create(exercise)
      expect { post_create(another_exercise) }.to change { PeerReview.count }.by(1)
    end
  end

  private

  def post_create(exercise)
    exercise_params = { exercise_id: exercise.id, tags: ['tagi'] }
    peer_review_params = { comment: 'Hyvin menee', answers: {} }
    post '/api/v0/peer_reviews', params: { exercise: exercise_params, peer_review: peer_review_params }
  end
end
