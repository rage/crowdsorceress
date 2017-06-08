class ChangeExerciseTypeIdToAssignmentIdFromExercises < ActiveRecord::Migration[5.1]
  def change
    rename_column :exercises, :type_id, :assignment_id
  end
end
