# frozen_string_literal: true

class PeerReview < ApplicationRecord
  belongs_to :user
  belongs_to :exercise
  has_many :peer_review_question_answers, dependent: :destroy

  validates :comment, presence: true
end

#  counter_cache: true
