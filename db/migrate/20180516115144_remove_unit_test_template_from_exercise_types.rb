# frozen_string_literal: true

class RemoveUnitTestTemplateFromExerciseTypes < ActiveRecord::Migration[5.1]
  def change
    remove_column :exercise_types, :unit_test_template
  end
end
