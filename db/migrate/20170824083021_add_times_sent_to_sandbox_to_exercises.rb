# frozen_string_literal: true

class AddTimesSentToSandboxToExercises < ActiveRecord::Migration[5.1]
  def change
    add_column :exercises, :times_sent_to_sandbox, :integer, default: 0, null: false
  end
end
