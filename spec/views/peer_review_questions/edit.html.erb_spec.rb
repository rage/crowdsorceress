# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'peer_review_questions/edit', type: :view do
  before(:each) do
    @peer_review_question = assign(:peer_review_question, PeerReviewQuestion.create!(
                                                            question: 'MyString',
                                                            exercise_type_id: ''
    ))
  end

  it 'renders the edit peer_review_question form' do
    render

    assert_select 'form[action=?][method=?]', peer_review_question_path(@peer_review_question), 'post' do
      assert_select 'input[name=?]', 'peer_review_question[question]'

      assert_select 'input[name=?]', 'peer_review_question[exercise_type_id]'
    end
  end
end
