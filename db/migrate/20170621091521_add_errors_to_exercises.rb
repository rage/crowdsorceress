# frozen_string_literal: true

class AddErrorsToExercises < ActiveRecord::Migration[5.1]
  def change
    add_column :exercises, :error_messages, :string
  end
end
