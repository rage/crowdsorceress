# frozen_string_literal: true

class PeerReview < ApplicationRecord
  belongs_to :user
  belongs_to :exercise, counter_cache: true
  has_many :peer_review_question_answers, dependent: :destroy
  has_many :peer_reviews_tags, dependent: :destroy
  has_many :tags, through: :peer_reviews_tags

  validates :comment, presence: true

  def draw_exercises(assignment, current_user, cnt)
    return [] if cnt.zero? || cnt.negative?
    regular_users = User.where(administrator: false)
    own = own_exercise(assignment, current_user)
    cnt += 1 if own.nil?
    exercises = assignment.exercises
                          .where(status: :finished)
                          .where(user: regular_users) # do not give random test exercises made by creators for students to review
                          .where.not(user: current_user)
                          .order('peer_reviews_count, RANDOM()')
                          .first(cnt - 1).to_a
    exercises << own unless own.nil?
    exercises
  end

  def own_exercise(assignment, current_user)
    assignment.exercises
              .where(status: :finished)
              .where(user: current_user)
              .order('peer_reviews_count, RANDOM()')
              .first
  end
end
