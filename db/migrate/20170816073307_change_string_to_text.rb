# frozen_string_literal: true

class ChangeStringToText < ActiveRecord::Migration[5.1]
  def change
    change_column :assignments, :description, :text
    change_column :exercise_types, :test_template, :text
    change_column :exercise_types, :code_template, :text
    change_column :exercises, :code, :text
    change_column :exercises, :model_solution, :text
    change_column :exercises, :template, :text
  end
end
