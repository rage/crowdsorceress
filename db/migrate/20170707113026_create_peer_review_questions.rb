# frozen_string_literal: true

class CreatePeerReviewQuestions < ActiveRecord::Migration[5.1]
  def change
    create_table :peer_review_questions do |t|
      t.string :question, null: false
      t.references :exercise_type, foreign_key: true

      t.timestamps
    end
  end
end
