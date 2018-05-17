class ChangeTestingTypeToEnum < ActiveRecord::Migration[5.1]
  def change
    remove_column :exercise_types, :testing_type, :string
    add_column :exercise_types, :testing_type, :integer, default: 0
  end
end
