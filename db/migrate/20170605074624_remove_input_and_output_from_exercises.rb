class RemoveInputAndOutputFromExercises < ActiveRecord::Migration[5.1]
  def change
    remove_column :exercises, :input
    remove_column :exercises, :output
  end
end
