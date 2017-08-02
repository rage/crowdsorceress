# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExercisesController, type: :controller do
  describe 'Exercise' do
    let(:user) { FactoryGirl.create(:user) }
    before { allow(controller).to receive(:current_user) { user } }

    context 'when created' do
      it 'is created correctly' do
        post_create
        assert_response 201
        expect { post_create }.to change { Exercise.count }.by(1)
      end
      it 'creates tag' do
        post_create
        expect { post_create }.to change { Tag.count }.by(1)
      end
    end

    it 'is not saved when a needed parameter is missing' do
      post :create, params: { exercise: { description: { a: 'asd' }, code: 'asd', testIO: { "input": 'asd', "output": 'asdf' } } }
      expect(response.status).to eq(400)
    end
  end

  private

  def post_create
    assignment = FactoryGirl.create(:assignment)

    params = { description: { a: 'asd' }, code: 'asd',
               testIO: { "input": 'asd', "output": 'asdf' }, assignment_id: assignment.id, tags: ['tägi'] }
    post :create, params: { exercise: params }
  end
end
