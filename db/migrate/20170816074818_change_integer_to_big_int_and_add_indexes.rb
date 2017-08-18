# frozen_string_literal: true

class ChangeIntegerToBigIntAndAddIndexes < ActiveRecord::Migration[5.1]
  def change
    change_column :exercises, :user_id, :bigint
    change_column :exercises, :assignment_id, :bigint
    add_index :exercises, :user_id
    add_index :exercises, :assignment_id
  end
end
