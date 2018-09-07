# frozen_string_literal: true

class AddTestMethodTemplateToExerciseTypes < ActiveRecord::Migration[5.1]
  def change
    add_column :exercise_types, :test_method_template, :string
  end
end
