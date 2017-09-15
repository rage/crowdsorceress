class AddInputTypeAndOutputTypeToExerciseType < ActiveRecord::Migration[5.1]
  def change
    add_column :exercise_types, :input_type, :string
    add_column :exercise_types, :output_type, :string
  end
end
