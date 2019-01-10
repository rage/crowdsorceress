# frozen_string_literal: true

class AddCourseAndPartToAssignments < ActiveRecord::Migration[5.1]
  def change
    add_column :assignments, :part, :integer
    add_column :assignments, :course_id, :integer
  end
end
