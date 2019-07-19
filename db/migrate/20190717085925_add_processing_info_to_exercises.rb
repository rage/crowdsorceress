# frozen_string_literal: true

class AddProcessingInfoToExercises < ActiveRecord::Migration[5.1]
  def change
    add_column :exercises, :processing_tried_at, :datetime, null: true
    add_column :exercises, :processing_began_at, :datetime, null: true
    add_column :exercises, :processing_completed_at, :datetime, null: true
    add_column :exercises, :times_sent_to_sandbox, :int, null: false, default: 0
  end
end
