require 'rails_helper'

RSpec.describe "exercises/index", type: :view do
  before(:each) do
    assign(:exercises, [
      Exercise.create!(
        :user_id => 2,
        :code => "MyText",
        :assignment_id => 3,
        :testIO => "",
        :description => "",
        :status => 4,
        :error_messages => "Error Messages",
        :sandbox_results => "MyText",
        :peer_reviews_count => 5,
        :model_solution => "MyText",
        :template => "MyText"
      ),
      Exercise.create!(
        :user_id => 2,
        :code => "MyText",
        :assignment_id => 3,
        :testIO => "",
        :description => "",
        :status => 4,
        :error_messages => "Error Messages",
        :sandbox_results => "MyText",
        :peer_reviews_count => 5,
        :model_solution => "MyText",
        :template => "MyText"
      )
    ])
  end

  it "renders a list of exercises" do
    render
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => 3.to_s, :count => 2
    assert_select "tr>td", :text => "".to_s, :count => 2
    assert_select "tr>td", :text => "".to_s, :count => 2
    assert_select "tr>td", :text => 4.to_s, :count => 2
    assert_select "tr>td", :text => "Error Messages".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => 5.to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
  end
end
