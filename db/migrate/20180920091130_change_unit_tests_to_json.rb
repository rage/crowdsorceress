# frozen_string_literal: true

class ChangeUnitTestsToJson < ActiveRecord::Migration[5.1]
  def change
    remove_column :exercises, :unit_tests, :text
    add_column :exercises, :unit_tests, :json, array: true, default: []
  end
end
