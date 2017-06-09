# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExercisesController, type: :controller do
  describe 'Exercise' do
    let(:user) { FactoryGirl.build(:user) }
    before { allow(controller).to receive(:current_user) { user } }

    it 'is created correctly' do
      post_create
      assert_response 201
      expect { post_create }.to change { Exercise.count }.by(1)
    end

    it 'is not saved when a needed parameter is missing' do
      exercise = Exercise.create
      expect(exercise.assignment_id).to be(nil)

      expect do
        post :create, params: { exercise: { description: 'asd', code: 'asd',
                                            testIO: { "input": 'asd', "output": 'asdf' } } }
      end.to change { Exercise.count }.by(0)
    end
  end

  private

  def post_create
    params = { description: 'asd', code: 'asd',
               testIO: { "input": 'asd', "output": 'asdf' }, assignment_id: 1 }
    post :create, params: { exercise: params }
  end
end
