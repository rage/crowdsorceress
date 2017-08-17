# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PeerReviewsController, type: :controller do
  let(:user) { FactoryGirl.create(:user) }
  before { allow(controller).to receive(:current_user) { user } }
  before :each do
    allow_any_instance_of(PeerReviewsController).to receive(:send_file)
  end

  let(:peer_review_question_question) { 'Testien kattavuus' }
  let(:exercise) { FactoryGirl.create(:exercise, user: user) }
  let(:another_exercise) { FactoryGirl.create(:exercise, user: user) }

  context 'when submitting again for same exercise' do
    it 'also creates tags in case exercise didn\'t have them' do
      expect { post_create(exercise) }.to change { Tag.count }.by(1)
    end
  end

  it 'is created correctly' do
    expect { post_create(exercise) }.to change { PeerReview.count }.by(1)
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

  it 'is not created without a related exercise' do
    answers = { 'Tehtävän mielekkyys': 5 }
    post :create, params: { exercise: { asd: 'asd' }, peer_review: { comment: 'Hyvin menee', answers: answers } }
    expect(response.status).to eq(400)
  end

  it 'is not created without a comment or answer' do
    exercise = FactoryGirl.create(:exercise, user: FactoryGirl.create(:user))
    post :create, params: { peer_review: { asd: 'asd' }, exercise: { exercise_id: exercise.id, tags: ['asd'] } }
    expect(response.status).to eq(422)
  end

  private

  def post_create(exercise)
    answers = { peer_review_question_question: 5 }

    exercise_params = { exercise_id: exercise.id, tags: ['tagi'] }
    peer_review_params = { comment: 'Hyvin menee', answers: answers }
    post :create, params: { exercise: exercise_params, peer_review: peer_review_params }
  end
end
