# frozen_string_literal: true

class PeerReview < ApplicationRecord
  belongs_to :user
  # TODO: counter_cache currently breaks tests
  belongs_to :exercise # , counter_cache: true
  has_many :peer_review_question_answers, dependent: :destroy

  validates :comment, presence: true

  def draw_exercise(assignment)
    reviewables = []
    exercises_to_assignment = Exercise.where(assignment: assignment).all

    # not tested with multiple exercises yet, only with array that has one exercise
    # also, counter_cache confuses me, but that's ok
    exercises_to_assignment.each do |ex|
      if ex.peer_reviews.size == least_reviewed(assignment)
        reviewable = exercises_to_assignment.find(ex.id)
      end
      reviewables.push(reviewable)
    end

    reviewables.sample
  end

  def least_reviewed(assignment)
    # TODO: clean this poor thing up, it looks like Java now
    max = 666
    smallest = 0
    exercises_to_assignment = Exercise.where(assignment: assignment).all
    exercises_to_assignment.each do |ex|
      smallest = ex.peer_reviews.size if ex.peer_reviews.size < max
    end
    smallest
  end
end
