# frozen_string_literal: true

class PeerReviewQuestionAnswer < ApplicationRecord
  belongs_to :peer_review
  belongs_to :peer_review_question
  has_one :exercise, through: :peer_review

  validates :grade, presence: true, numericality: { only_integer: true, greater_than: 0, less_than: 6 }
end
