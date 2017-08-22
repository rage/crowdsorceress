# frozen_string_literal: true

class ChangeExerciseErrorMessagesFormAgain < ActiveRecord::Migration[5.1]
  def change
    remove_column :exercises, :template_errors, :json
    remove_column :exercises, :model_solution_errors, :json, array: true
    add_column :exercises, :error_messages, :json, array: true
  end
end
