# frozen_string_literal: true

class PreventCodeTemplatesFromBeingNullFromExerciseTypes < ActiveRecord::Migration[5.1]
  def change
    change_column :exercise_types, :code_template, :text, default: '', null: false
  end
end
