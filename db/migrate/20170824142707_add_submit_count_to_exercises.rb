# frozen_string_literal: true

class AddSubmitCountToExercises < ActiveRecord::Migration[5.1]
  def change
    add_column :exercises, :submit_count, :integer, default: 0, null: false
  end
end
