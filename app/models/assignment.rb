class Assignment < ApplicationRecord
  belongs_to :exercise_type
  has_many :exercises
end
