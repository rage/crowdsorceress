# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExercisesController, type: :controller do
  describe 'Exercise' do
    let(:user) { FactoryGirl.create(:user) }
    let(:assignment) { FactoryGirl.create(:assignment) }
    before { allow(controller).to receive(:current_user) { user } }

    it 'is created correctly' do
      post_create(assignment)
      assert_response 201
      expect { post_create(assignment) }.to change { Exercise.count }.by(1)
    end

    it 'is not saved when a needed parameter is missing' do
      exercise = Exercise.create
      expect(exercise.assignment_id).to be(nil)

      expect do
        post :create, params: { exercise: { description: { a: 'asd' }, code: 'asd',
                                            testIO: { "input": 'asd', "output": 'asdf' } } }
      end.to change { Exercise.count }.by(0)
    end
  end

  private

  def post_create(assignment)
    params = { description: { a: 'asd' }, code: 'asd',
               testIO: { "input": 'asd', "output": 'asdf' }, assignment_id: assignment.id }
    post :create, params: { exercise: params }
  end
end
