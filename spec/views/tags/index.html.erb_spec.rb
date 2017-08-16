# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'tags/index', type: :view do
  before(:each) do
    assign(:tags, [
             Tag.create!(
               name: 'Name',
               recommended: false
             ),
             Tag.create!(
               name: 'Name',
               recommended: false
             )
           ])
  end

  it 'renders a list of tags' do
    render
    assert_select 'tr>td', text: 'Name'.to_s, count: 2
    assert_select 'tr>td', text: false.to_s, count: 2
  end
end
