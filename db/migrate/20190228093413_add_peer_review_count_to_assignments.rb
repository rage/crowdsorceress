# frozen_string_literal: true

class AddPeerReviewCountToAssignments < ActiveRecord::Migration[5.1]
  def change
    add_column :assignments, :peer_review_count, :integer, default: 0
  end
end
