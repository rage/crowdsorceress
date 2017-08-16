# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'peer_reviews/edit', type: :view do
  before(:each) do
    @peer_review = assign(:peer_review, PeerReview.create!(
                                          user_id: '',
                                          exercise_id: '',
                                          comment: 'MyText'
    ))
  end

  it 'renders the edit peer_review form' do
    render

    assert_select 'form[action=?][method=?]', peer_review_path(@peer_review), 'post' do
      assert_select 'input[name=?]', 'peer_review[user_id]'

      assert_select 'input[name=?]', 'peer_review[exercise_id]'

      assert_select 'textarea[name=?]', 'peer_review[comment]'
    end
  end
end
