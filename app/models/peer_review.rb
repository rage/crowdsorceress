# frozen_string_literal: true

class PeerReview < ApplicationRecord
  belongs_to :user
  belongs_to :exercise, counter_cache: true
  has_many :peer_review_question_answers, dependent: :destroy
  has_many :peer_reviews_tags, dependent: :destroy
  has_many :tags, through: :peer_reviews_tags

  validates :comment, presence: true

  def draw_exercise(assignment)
    regular_users = User.where(administrator: false)

    assignment.exercises
              .where(status: :finished)
              .where(user: regular_users) # do not give random test exercises made by creators for students to review
              .order('peer_reviews_count, RANDOM()')
              .first
  end
end
