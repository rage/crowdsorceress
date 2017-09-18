# frozen_string_literal: true

class ChangeUserAdministratorToNeverBeNull < ActiveRecord::Migration[5.1]
  def change
    change_column_null :users, :administrator, false
    change_column_default :users, :administrator, from: nil, to: false

    reversible do |dir|
      dir.up do
        User.where(administrator: nil).update_all(administrator: false)
      end
    end
  end
end
