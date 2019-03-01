# frozen_string_literal: true

class AddPrPartToAssignments < ActiveRecord::Migration[5.1]
  def change
    add_column :assignments, :pr_part, :string
  end
end
