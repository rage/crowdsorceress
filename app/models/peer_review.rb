# frozen_string_literal: true

class PeerReview < ApplicationRecord
  belongs_to :user
  belongs_to :exercise, counter_cache: true
  has_many :peer_review_question_answers, dependent: :destroy

  validates :comment, presence: true

  def draw_exercise
    # TODO: only go through exercises related to assignment at hand, not all of the exercises
    reviewables = Exercise.find(PeerReviews.count == least_reviewed)
    reviewables.shuffle.first
  end

  def least_reviewed
    # TODO: find exercises with least reviews, return count of those reviews
  end
end


