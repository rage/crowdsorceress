class AddSandboxResultsToExercises < ActiveRecord::Migration[5.1]
  def change
    add_column :exercises, :sandbox_results, :text
  end
end
