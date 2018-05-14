# frozen_string_literal: true

class AddJunitTestsToExercises < ActiveRecord::Migration[5.1]
  def change
    add_column :exercises, :junit_tests, :text
  end
end
