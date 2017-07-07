# frozen_string_literal: true

class PeerReviewQuestionAnswer < ApplicationRecord
  belongs_to :peer_review
  belongs_to :peer_review_question
  belongs_to :exercise, through: :peer_review
end
