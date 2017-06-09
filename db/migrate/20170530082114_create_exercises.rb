# frozen_string_literal: true

class CreateExercises < ActiveRecord::Migration[5.1]
  def change
    create_table :exercises do |t|
      t.integer :user_id
      t.string :code
      t.string :description
      t.string :input
      t.string :output
      t.integer :type_id

      t.timestamps
    end
  end
end
