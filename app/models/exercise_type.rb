# frozen_string_literal: true

class ExerciseType < ApplicationRecord
  has_many :exercises
end
