# frozen_string_literal: true

class PeerReview < ApplicationRecord
  belongs_to :user
  belongs_to :exercise, counter_cache: true
  has_many :peer_review_question_answers, dependent: :destroy

  validates :comment, presence: true

  def draw_exercise(assignment)
    assignment.exercises.where(status: :finished).order('peer_reviews_count, RANDOM()').first
  end
end
