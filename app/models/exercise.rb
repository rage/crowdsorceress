class Exercise < ApplicationRecord
  belongs_to :exercise_type, foreign_key: 'type_id'
  belongs_to :user

  def find_type
    #TODO
    type_id
  end
end
