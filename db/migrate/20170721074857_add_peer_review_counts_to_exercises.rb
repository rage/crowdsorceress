# frozen_string_literal: true

class AddPeerReviewCountsToExercises < ActiveRecord::Migration[5.1]
  def change
    change_table :exercises do |t|
      t.integer :peer_reviews_count, default: 0
    end

    reversible do |dir|
      dir.up { data }
    end
  end

  def data
    execute <<-SQL.squish
        UPDATE exercises
           SET peer_reviews_count = (SELECT count(1)
                                   FROM peer_reviews
                                  WHERE peer_reviews.exercise_id = exercises.id)
    SQL
  end
end
