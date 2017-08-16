# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'assignments/index', type: :view do
  before(:each) do
    assign(:assignments, [
             Assignment.create!(
               description: 'Description',
               exercise_type_id: 2
             ),
             Assignment.create!(
               description: 'Description',
               exercise_type_id: 2
             )
           ])
  end

  it 'renders a list of assignments' do
    render
    assert_select 'tr>td', text: 'Description'.to_s, count: 2
    assert_select 'tr>td', text: 2.to_s, count: 2
  end
end
