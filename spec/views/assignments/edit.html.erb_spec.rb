require 'rails_helper'

RSpec.describe "assignments/edit", type: :view do
  before(:each) do
    @assignment = assign(:assignment, Assignment.create!(
      :description => "MyString",
      :exercise_type_id => 1
    ))
  end

  it "renders the edit assignment form" do
    render

    assert_select "form[action=?][method=?]", assignment_path(@assignment), "post" do

      assert_select "input[name=?]", "assignment[description]"

      assert_select "input[name=?]", "assignment[exercise_type_id]"
    end
  end
end
