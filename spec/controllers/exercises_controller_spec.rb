require 'rails_helper'

RSpec.describe ExercisesController, type: :controller do
  describe 'Exercise' do
    let (:user){ FactoryGirl.create(:user) }
    # let (:exercise){ FactoryGirl.create(:exercise) }
    let (:type){ FactoryGirl.create(:exercise_type) }
    before { allow(controller).to receive(:current_user) { user } }

    it 'is created correctly from json' do
      post_create
      assert_response 201
      expect { post_create }.to change { Exercise.count }.by(1)
    end

    it 'is not created when params are not json' do
      expect do
        post :create, params: { exercise: { user_id: user.id, description: 'asd', code: 'asd',
                                            testIO: 'asd', type_id: type.id } }
      end.to raise_error(TypeError)
      expect(Exercise.count).to eq(0)
    end

    it 'is not saved when required params are missing' do
      exercise = Exercise.create user_id: user.id
      exercise2 = Exercise.create type_id: type.id

      expect(exercise.type_id).to be(nil)
      expect(exercise2.user_id).to be(nil)
      expect(Exercise.count).to eq(0)
    end
  end

  private

  def post_create
    json_params = { description: 'asd', code: 'asd',
                    testIO: 'asd', type_id: type.id }.to_json
    post :create, params: { exercise: json_params }
  end
end
