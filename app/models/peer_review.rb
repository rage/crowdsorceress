# frozen_string_literal: true

class PeerReview < ApplicationRecord
  belongs_to :user
  belongs_to :exercise, counter_cache: true
  has_many :peer_review_question_answers, dependent: :destroy
  has_many :peer_reviews_tags, dependent: :destroy
  has_many :tags, through: :peer_reviews_tags

  validates :comment, presence: true

  def draw_exercise(assignment)
    assignment.exercises
              .where(status: :finished)
              .order('peer_reviews_count, RANDOM()')
              .first
  end

  def fetch_recommended_tags
    Tag.where recommended: true
  end
end
