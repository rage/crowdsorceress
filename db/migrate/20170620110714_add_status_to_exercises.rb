# frozen_string_literal: true

class AddStatusToExercises < ActiveRecord::Migration[5.1]
  def change
    add_column :exercises, :status, :integer, default: 0
  end
end
