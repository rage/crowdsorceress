# frozen_string_literal: true

class PeerReview < ApplicationRecord
  belongs_to :user
  belongs_to :exercise, counter_cache: true
  has_many :peer_review_question_answers, dependent: :destroy

  validates :comment, presence: true

  def draw_exercise(assignment)
    exercises_to_assignment = Exercise.where(assignment: assignment, status: 'finished')
    reviewables = exercises_to_assignment.select { |ex| ex.peer_reviews.size == least_reviewed(assignment) }
    reviewables.sample
  end

  def least_reviewed(assignment)
    exercises_to_assignment = Exercise.where(assignment: assignment, status: 'finished')
    smallest = exercises_to_assignment.first.peer_reviews.size
    exercises_to_assignment.each do |ex|
      smallest = ex.peer_reviews.size if ex.peer_reviews.size < smallest
    end
    smallest
  end
end
