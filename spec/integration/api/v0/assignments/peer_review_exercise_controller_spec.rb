# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V0::Assignments::PeerReviewExerciseController, type: :request do
  let(:user) { FactoryGirl.create(:user) }
  before { allow(controller).to receive(:current_user) { user } }
  let(:exercise) { FactoryGirl.create(:exercise, user: user) }

  it 'assigns exercises for reviewing' do
    exercise.update status: 'finished'
    get "/api/v0/assignments/#{exercise.assignment.id}/peer_review_exercise?count=3"
    expect(response.status).to eq(200)
  end

  it 'handles error when requesting an exercise for assignment that has no finished exercises' do
    Assignment.first.exercises = []
    get "/api/v0/assignments/#{Assignment.first.id}/peer_review_exercise?count=3"
    expect(response.status).to eq(400)
  end
end
