# frozen_string_literal: true

class RemoveNegTestIoFromExercises < ActiveRecord::Migration[5.1]
  def change
    remove_column :exercises, :negTestIO, :json
  end
end
