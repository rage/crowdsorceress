# frozen_string_literal: true

class CreateAssignments < ActiveRecord::Migration[5.1]
  def change
    create_table :assignments do |t|
      t.string :description
      t.references :exercise_type, foreign_key: true

      t.timestamps
    end
  end
end
