# frozen_string_literal: true

class CreateTags < ActiveRecord::Migration[5.1]
  def change
    create_table :tags do |t|
      t.string :name

      t.timestamps
    end

    create_table :exercises_tags do |t|
      t.references :tag, foreign_key: true
      t.references :exercise, foreign_key: true
    end

    create_table :peer_reviews_tags do |t|
      t.references :tag, foreign_key: true
      t.references :peer_review, foreign_key: true
    end
  end
end
