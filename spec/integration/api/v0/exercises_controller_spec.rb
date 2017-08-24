# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V0::ExercisesController, type: :request do
  let(:assignment) { FactoryGirl.create(:assignment) }
  let(:user) { FactoryGirl.create(:user) }
  before { allow_any_instance_of(Api::V0::ExercisesController).to receive(:current_user).and_return(user) }
  before :each do
    allow_any_instance_of(Api::V0::ExercisesController).to receive(:send_submission)
  end

  describe 'Exercise' do
    it 'is created correctly' do
      expect do
        post '/api/v0/exercises', params: { exercise: { description: { a: 'asd' }, code: 'asd',
                                                        testIO: [{ "input": 'asd', "output": 'asdf' }],
                                                        assignment_id: assignment.id, tags: ['tägi'] } }
      end
        .to change { Exercise.count }.by(1)
      assert_response 201
    end

    it 'creates tag' do
      expect do
        post '/api/v0/exercises', params: { exercise: { description: { a: 'asd' }, code: 'asd',
                                                        testIO: [{ "input": 'asd', "output": 'asdf' }],
                                                        assignment_id: assignment.id, tags: ['kissaaaaaa'] } }
      end
        .to change { Tag.count }.by(1)
    end

    it 'is not saved when a needed parameter is missing' do
      post '/api/v0/exercises', params: { exercise: { description: { a: 'asd' }, code: 'asd', testIO: { "input": 'asd', "output": 'asdf' } } }
      expect(response.status).to eq(400)
    end
  end
end
