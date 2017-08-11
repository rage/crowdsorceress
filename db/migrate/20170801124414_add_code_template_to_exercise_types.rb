# frozen_string_literal: true

class AddCodeTemplateToExerciseTypes < ActiveRecord::Migration[5.1]
  def change
    add_column :exercise_types, :code_template, :string
  end
end
