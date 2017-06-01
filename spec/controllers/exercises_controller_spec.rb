require 'rails_helper'

RSpec.describe ExercisesController, type: :controller do
  def post_create
    user = User.create
    type = ExerciseType.create
    json_params = { user_id: user.id, description: 'asd', code: 'asd',
                    input: 'asd', output: 'asd', type_id: type.id }.to_json
    post :create, params: { exercise: json_params }
  end

  it 'is created correctly from json' do
    post_create
    # expect(response.status).to eq(201)
    assert_response 201
    expect { post_create }.to change { Exercise.count }.by(1)

  end

  it 'is not created when params are not json' do
    user = User.create
    type = ExerciseType.create
    expect { post :create, params: { exercise: { user_id: user.id, description: 'asd', code: 'asd',
                    input: 'asd', output: 'asd', type_id: type.id }} }.to raise_error(TypeError)
    expect(Exercise.count).to eq(0)
  end
  
end
