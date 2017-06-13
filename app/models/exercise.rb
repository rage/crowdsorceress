# frozen_string_literal: true

class Exercise < ApplicationRecord
  belongs_to :assignment
  belongs_to :user

  validates :description, presence: true
  validates :testIO, presence: true
  validates :code, presence: true

  def test_exercise_in_sandbox
    # TODO
  end

  def parse_exercise
    # TODO
  end
end
