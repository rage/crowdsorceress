# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PeerReviewQuestionAnswer, type: :model do
  subject { described_class.new }

  it 'is not valid without a grade or comment' do
    subject.peer_review_id = 1
    subject.peer_review_question_id = 1
    expect(subject).not_to be_valid
  end

  it 'validates a numeric grade between 1 and 5' do
    subject.peer_review_id = 1
    subject.peer_review_question_id = 1
    subject.grade = 100
    expect(subject).not_to be_valid
    subject.grade = 'lol'
    expect(subject).not_to be_valid
  end

  it 'validates a correct peer review answer' do
    peer_review = FactoryGirl.create(:peer_review)
    peer_review_question = FactoryGirl.create(:peer_review_question)
    subject.peer_review_id = peer_review.id
    subject.peer_review_question_id = peer_review_question.id
    subject.grade = 5
    expect(subject).to be_valid
  end
end
