# frozen_string_literal: true

class ExercisesTag < ApplicationRecord
  belongs_to :exercise
  belongs_to :tag # counter_cache: true
end
