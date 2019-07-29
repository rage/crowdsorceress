# frozen_string_literal: true

class AddLanguageToCourses < ActiveRecord::Migration[5.1]
  def change
    add_column :courses, :language, :string
  end
end
