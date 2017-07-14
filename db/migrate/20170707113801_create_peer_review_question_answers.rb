# frozen_string_literal: true

class CreatePeerReviewQuestionAnswers < ActiveRecord::Migration[5.1]
  def change
    create_table :peer_review_question_answers do |t|
      t.integer :grade, null: false
      t.references :peer_review, foreign_key: true
      t.references :peer_review_question, foreign_key: true

      t.timestamps
    end
  end
end
