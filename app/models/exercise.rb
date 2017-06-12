# frozen_string_literal: true

class Exercise < ApplicationRecord
  belongs_to :assignment
  belongs_to :user

  def test_exercise_in_sandbox
    # TODO
  end

  def parse_exercise
    # TODO
  end
end
