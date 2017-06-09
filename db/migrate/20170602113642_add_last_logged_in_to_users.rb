# frozen_string_literal: true

class AddLastLoggedInToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :last_logged_in, :time
  end
end
