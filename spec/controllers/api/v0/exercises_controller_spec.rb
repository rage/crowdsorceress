# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V0::ExercisesController, type: :controller do
  let(:user) { FactoryGirl.create(:user) }
  before { allow(controller).to receive(:current_user) { user } }

  it 'is created correctly' do
    post_create
    assert_response 201
    expect { post_create }.to change { Exercise.count }.by(1)
  end

  it 'creates tag' do
    post_create
    expect { post_create }.to change { Tag.count }.by(1)
  end

  private

  def post_create
    assignment = FactoryGirl.create(:assignment)

    params = { description: { a: 'asd' }, code: 'asd',
               testIO: { "input": 'asd', "output": 'asdf' }, assignment_id: assignment.id, tags: ['tägi'] }
    post :create, params: { exercise: params }
  end
end
