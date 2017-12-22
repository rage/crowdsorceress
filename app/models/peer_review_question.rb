# frozen_string_literal: true

class PeerReviewQuestion < ApplicationRecord
  belongs_to :exercise_type
  has_many :peer_review_question_answers
end
