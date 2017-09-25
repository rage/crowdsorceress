# frozen_string_literal: true

class AddNegativeTestIoToExercises < ActiveRecord::Migration[5.1]
  def change
    add_column :exercises, :negTestIO, :json
  end
end
