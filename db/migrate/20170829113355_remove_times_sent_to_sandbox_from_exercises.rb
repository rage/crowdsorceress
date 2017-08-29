# frozen_string_literal: true

class RemoveTimesSentToSandboxFromExercises < ActiveRecord::Migration[5.1]
  def change
    remove_column :exercises, :times_sent_to_sandbox, :integer
  end
end
