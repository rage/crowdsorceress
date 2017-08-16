# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'peer_reviews/index', type: :view do
  before(:each) do
    assign(:peer_reviews, [
             PeerReview.create!(
               user_id: '',
               exercise_id: '',
               comment: 'MyText'
             ),
             PeerReview.create!(
               user_id: '',
               exercise_id: '',
               comment: 'MyText'
             )
           ])
  end

  it 'renders a list of peer_reviews' do
    render
    assert_select 'tr>td', text: ''.to_s, count: 2
    assert_select 'tr>td', text: ''.to_s, count: 2
    assert_select 'tr>td', text: 'MyText'.to_s, count: 2
  end
end
