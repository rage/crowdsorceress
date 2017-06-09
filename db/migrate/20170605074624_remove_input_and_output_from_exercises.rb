# frozen_string_literal: true

class RemoveInputAndOutputFromExercises < ActiveRecord::Migration[5.1]
  def change
    remove_column :exercises, :input, :string
    remove_column :exercises, :output, :string
  end
end
