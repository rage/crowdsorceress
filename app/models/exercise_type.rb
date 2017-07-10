# frozen_string_literal: true

class ExerciseType < ApplicationRecord
  has_many :exercises
  has_many :peer_review_questions
end
