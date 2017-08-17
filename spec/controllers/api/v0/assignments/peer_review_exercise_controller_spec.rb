# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V0::Assignments::PeerReviewExerciseController, type: :controller do
  let(:user) { FactoryGirl.create(:user) }
  before { allow(controller).to receive(:current_user) { user } }
  let(:exercise) { FactoryGirl.create(:exercise, user: user) }

  it 'assigns an exercise for reviewing' do
    exercise.update status: 'finished'
    get :index, params: { assignment_id: exercise.assignment_id }
    expect(response.status).to eq(200)
  end

  it 'handles error when requesting an exercise for assignment that has no finished exercises' do
    Assignment.first.exercises = []
    get :index, params: { assignment_id: Assignment.first.id }
    expect(response.status).to eq(400)
  end
end
