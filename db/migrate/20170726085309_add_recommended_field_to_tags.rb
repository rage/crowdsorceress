# frozen_string_literal: true

class AddRecommendedFieldToTags < ActiveRecord::Migration[5.1]
  def change
    add_column :tags, :recommended, :boolean, default: false
  end
end
