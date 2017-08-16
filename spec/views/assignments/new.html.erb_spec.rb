# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'assignments/new', type: :view do
  before(:each) do
    assign(:assignment, Assignment.new(
                          description: 'MyString',
                          exercise_type_id: 1
    ))
  end

  it 'renders new assignment form' do
    render

    assert_select 'form[action=?][method=?]', assignments_path, 'post' do
      assert_select 'input[name=?]', 'assignment[description]'

      assert_select 'input[name=?]', 'assignment[exercise_type_id]'
    end
  end
end
