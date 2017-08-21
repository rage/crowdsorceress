class ChangeDefaultValueToExerciseErrorMessages < ActiveRecord::Migration[5.1]
  def change
    change_column :exercises, :error_messages, :json, array: true, default: []
  end
end
