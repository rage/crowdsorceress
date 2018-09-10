# frozen_string_literal: true

class RenameJunitTestsToUnitTests < ActiveRecord::Migration[5.1]
  def change
    rename_column :exercises, :junit_tests, :unit_tests
    # rename_column :exercise_types, :junit_test_template, :unit_test_template
    add_column :exercise_types, :unit_test_template, :text
  end
end
