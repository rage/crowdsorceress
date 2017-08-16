# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'peer_review_questions/new', type: :view do
  before(:each) do
    assign(:peer_review_question, PeerReviewQuestion.new(
                                    question: 'MyString',
                                    exercise_type_id: ''
    ))
  end

  it 'renders new peer_review_question form' do
    render

    assert_select 'form[action=?][method=?]', peer_review_questions_path, 'post' do
      assert_select 'input[name=?]', 'peer_review_question[question]'

      assert_select 'input[name=?]', 'peer_review_question[exercise_type_id]'
    end
  end
end
