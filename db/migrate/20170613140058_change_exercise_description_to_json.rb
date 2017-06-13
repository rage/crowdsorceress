# frozen_string_literal: true

class ChangeExerciseDescriptionToJson < ActiveRecord::Migration[5.1]
  def change
    remove_column :exercises, :description, :string
    add_column :exercises, :description, :json
  end
end
