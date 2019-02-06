# frozen_string_literal: true

class AddOptionalFieldsToAssignments < ActiveRecord::Migration[5.1]
  def change
    add_column :assignments, :show_results_to_user, :boolean, default: true
    add_column :assignments, :mandatory_tags, :boolean, default: true
  end
end
