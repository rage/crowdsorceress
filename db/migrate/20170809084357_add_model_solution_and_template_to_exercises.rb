# frozen_string_literal: true

class AddModelSolutionAndTemplateToExercises < ActiveRecord::Migration[5.1]
  def change
    add_column :exercises, :model_solution, :string
    add_column :exercises, :template, :string
  end
end
