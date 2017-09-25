# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V0::Assignments::PeerReviewExerciseController, type: :request do
  let(:user) { FactoryGirl.create(:user) }
  before { allow(controller).to receive(:current_user) { user } }
  before { allow_any_instance_of(Api::V0::BaseController).to receive(:ensure_signed_in!) }
  let(:exercise) { FactoryGirl.create(:exercise, user: user, status: 'finished') }

  it 'assigns exercises for reviewing' do
    get "/api/v0/assignments/#{exercise.assignment_id}/peer_review_exercise?count=3"
    expect(response.status).to eq(200)
  end

  it 'assigns an exercise for self review when possible' do
    get "/api/v0/assignments/#{exercise.assignment_id}/peer_review_exercise?count=3"
    expect(response.status).to eq(200)
    expect(response.body).to include(user.id.to_s)
  end

  it 'handles error when requesting an exercise for assignment that has no finished exercises' do
    Assignment.first.exercises = []
    get "/api/v0/assignments/#{Assignment.first.id}/peer_review_exercise?count=3"
    expect(response.status).to eq(400)
  end
end
