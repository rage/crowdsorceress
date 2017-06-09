# frozen_string_literal: true

class CreateExerciseTypes < ActiveRecord::Migration[5.1]
  def change
    create_table :exercise_types do |t|
      t.string :name
      t.string :test_template

      t.timestamps
    end
  end
end
