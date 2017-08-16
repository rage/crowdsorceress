require 'rails_helper'

RSpec.describe "exercise_types/show", type: :view do
  before(:each) do
    @exercise_type = assign(:exercise_type, ExerciseType.create!(
      :name => "Name",
      :test_template => "Test Template",
      :code_template => "Code Template"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/Test Template/)
    expect(rendered).to match(/Code Template/)
  end
end
