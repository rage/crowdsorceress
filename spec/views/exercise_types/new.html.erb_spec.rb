require 'rails_helper'

RSpec.describe "exercise_types/new", type: :view do
  before(:each) do
    assign(:exercise_type, ExerciseType.new(
      :name => "MyString",
      :test_template => "MyString",
      :code_template => "MyString"
    ))
  end

  it "renders new exercise_type form" do
    render

    assert_select "form[action=?][method=?]", exercise_types_path, "post" do

      assert_select "input[name=?]", "exercise_type[name]"

      assert_select "input[name=?]", "exercise_type[test_template]"

      assert_select "input[name=?]", "exercise_type[code_template]"
    end
  end
end
