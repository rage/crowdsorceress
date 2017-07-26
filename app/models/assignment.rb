# frozen_string_literal: true

class Assignment < ApplicationRecord
  belongs_to :exercise_type
  has_many :exercises

  def fetch_recommended_tags
    Tag.where recommended: true
  end
end
