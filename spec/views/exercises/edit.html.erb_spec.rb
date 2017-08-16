require 'rails_helper'

RSpec.describe "exercises/edit", type: :view do
  before(:each) do
    @exercise = assign(:exercise, Exercise.create!(
      :user_id => 1,
      :code => "MyText",
      :assignment_id => 1,
      :testIO => "",
      :description => "",
      :status => 1,
      :error_messages => "MyString",
      :sandbox_results => "MyText",
      :peer_reviews_count => 1,
      :model_solution => "MyText",
      :template => "MyText"
    ))
  end

  it "renders the edit exercise form" do
    render

    assert_select "form[action=?][method=?]", exercise_path(@exercise), "post" do

      assert_select "input[name=?]", "exercise[user_id]"

      assert_select "textarea[name=?]", "exercise[code]"

      assert_select "input[name=?]", "exercise[assignment_id]"

      assert_select "input[name=?]", "exercise[testIO]"

      assert_select "input[name=?]", "exercise[description]"

      assert_select "input[name=?]", "exercise[status]"

      assert_select "input[name=?]", "exercise[error_messages]"

      assert_select "textarea[name=?]", "exercise[sandbox_results]"

      assert_select "input[name=?]", "exercise[peer_reviews_count]"

      assert_select "textarea[name=?]", "exercise[model_solution]"

      assert_select "textarea[name=?]", "exercise[template]"
    end
  end
end
