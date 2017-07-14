# frozen_string_literal: true

class CreatePeerReviews < ActiveRecord::Migration[5.1]
  def change
    create_table :peer_reviews do |t|
      t.references :user, foreign_key: true
      t.references :exercise, foreign_key: true
      t.text :comment, null: false

      t.timestamps
    end
  end
end
