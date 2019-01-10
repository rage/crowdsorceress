# frozen_string_literal: true

class Assignment < ApplicationRecord
  belongs_to :exercise_type
  has_many :exercises
  belongs_to :course

  validates :description, presence: true
end
