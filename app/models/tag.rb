# frozen_string_literal: true

class Tag < ApplicationRecord
  has_many :exercises_tags
  has_many :peer_reviews_tags
  has_many :exercises, through: :exercises_tags
  has_many :peer_reviews, through: :peer_reviews_tags

  scope :recommended, -> { where(recommended: true) }
end
