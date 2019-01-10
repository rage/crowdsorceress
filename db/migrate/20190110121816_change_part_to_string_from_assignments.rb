# frozen_string_literal: true

class ChangePartToStringFromAssignments < ActiveRecord::Migration[5.1]
  def change
    change_column :assignments, :part, :string
  end
end
