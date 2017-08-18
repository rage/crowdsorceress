# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V0::Exercises::ZipsController, type: :request do
  let(:user) { FactoryGirl.create(:user) }
  let(:exercise) { FactoryGirl.create(:exercise, user: user) }
  before :each do
    allow_any_instance_of(Api::V0::Exercises::ZipsController).to receive(:send_file)
  end

  it 'sends zips' do
    FileUtils.mkdir_p(Rails.root.join('submission_generation', 'packages', "assignment_#{exercise.assignment_id}", "exercise_#{exercise.id}").to_s)
    FileUtils.touch(Rails.root.join(
      'submission_generation', 'packages', "assignment_#{exercise.assignment_id}", "exercise_#{exercise.id}", "ModelSolution_#{exercise.id}.1.zip"
    ).to_s)
    FileUtils.touch(Rails.root.join(
      'submission_generation', 'packages', "assignment_#{exercise.assignment_id}", "exercise_#{exercise.id}", "Stub_#{exercise.id}.1.zip"
    ).to_s)

    get "/api/v0/exercises/#{exercise.id}/model_solution.zip"
    expect(response.status).to eq(204)
    get "/api/v0/exercises/#{exercise.id}/template.zip"
    expect(response.status).to eq(204)

    FileUtils.remove_dir(Rails.root.join('submission_generation', 'packages', "assignment_#{exercise.assignment_id}").to_s)
  end
end
