# frozen_string_literal: true

class ChangeExerciseErrorMessagesForm < ActiveRecord::Migration[5.1]
  def change
    remove_column :exercises, :error_messages, :string, array: true
    add_column :exercises, :template_errors, :json
    add_column :exercises, :model_solution_errors, :json, array: true
  end
end
