# frozen_string_literal: true

class AddTestingTypeToExerciseTypes < ActiveRecord::Migration[5.1]
  def change
    add_column :exercise_types, :testing_type, :string
  end
end
