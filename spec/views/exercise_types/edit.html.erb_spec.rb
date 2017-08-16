# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'exercise_types/edit', type: :view do
  before(:each) do
    @exercise_type = assign(:exercise_type, ExerciseType.create!(
                                              name: 'MyString',
                                              test_template: 'MyString',
                                              code_template: 'MyString'
    ))
  end

  it 'renders the edit exercise_type form' do
    render

    assert_select 'form[action=?][method=?]', exercise_type_path(@exercise_type), 'post' do
      assert_select 'input[name=?]', 'exercise_type[name]'

      assert_select 'input[name=?]', 'exercise_type[test_template]'

      assert_select 'input[name=?]', 'exercise_type[code_template]'
    end
  end
end
