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
    post :create, params: { peer_review: { asd: 'asd' }, exercise: { exercise_id: exercise.id } }
    expect(response.status).to eq(422)
  end

  it 'sends zips' do
    FileUtils.mkdir_p(Rails.root.join('submission_generation', 'packages', 'assignment_1', 'exercise_1').to_s)
    FileUtils.touch(Rails.root.join('submission_generation', 'packages', 'assignment_1', 'exercise_1', 'ModelSolution_1.1.zip').to_s)
    FileUtils.touch(Rails.root.join('submission_generation', 'packages', 'assignment_1', 'exercise_1', 'Stub_1.1.zip').to_s)

    get :send_model_zip, params: { id: 1 }
    expect(response.status).to eq(204)
    get :send_stub_zip, params: { id: 1 }
    expect(response.status).to eq(204)

    FileUtils.remove_dir(Rails.root.join('submission_generation', 'packages', 'assignment_1').to_s)
  end

  it 'assigns an exercise for reviewing' do
    exercise.update status: 'finished'
    get :assign_exercise, params: { assignment_id: exercise.assignment_id }
    expect(response.status).to eq(200)
  end

  it 'handles error when requesting an exercise for assignment that has no finished exercises' do
    Assignment.first.exercises = []
    response = get :assign_exercise, params: { assignment_id: Assignment.first.id }
    expect(response.status).to eq(400)
  end

  private

  def post_create(exercise)
    answers = { peer_review_question_question: 5 }

    exercise_params = { exercise_id: exercise.id }
    peer_review_params = { comment: 'Hyvin menee', answers: answers }
    post :create, params: { exercise: exercise_params, peer_review: peer_review_params }
  end
end
