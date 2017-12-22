# frozen_string_literal: true

class Tag < ApplicationRecord
  has_many :exercises_tags, dependent: :destroy
  has_many :peer_reviews_tags, dependent: :destroy
  has_many :exercises, through: :exercises_tags
  has_many :peer_reviews, through: :peer_reviews_tags

  scope :recommended, -> { where(recommended: true) }

  validates :name, uniqueness: true

  def exercises_via_peer_reviews
    PeerReviewsTag.where(tag: self).map { |prt| prt.peer_review.exercise }.uniq
  end
end
