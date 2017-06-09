# frozen_string_literal: true

class ChangeIoToTestIoInExercises < ActiveRecord::Migration[5.1]
  def change
    rename_column :exercises, :IO, :testIO
  end
end
