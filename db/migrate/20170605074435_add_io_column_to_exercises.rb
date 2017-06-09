# frozen_string_literal: true

class AddIoColumnToExercises < ActiveRecord::Migration[5.1]
  def change
    add_column :exercises, :IO, :json
  end
end
