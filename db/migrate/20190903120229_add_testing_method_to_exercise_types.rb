# frozen_string_literal: true

class AddTestingMethodToExerciseTypes < ActiveRecord::Migration[5.1]
  def change
    add_column :exercise_types, :testing_a_method, :boolean
  end
end
