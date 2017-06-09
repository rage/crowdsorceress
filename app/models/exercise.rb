# frozen_string_literal: true

class Exercise < ApplicationRecord
  belongs_to :assignment
  belongs_to :user

  def find_type
    # TODO
    type_id
  end

  def test_exercise_in_sandbox
    # TODO
  end
end
