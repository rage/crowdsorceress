# frozen_string_literal: true

class Exercise < ApplicationRecord
  belongs_to :assignment
  belongs_to :user

  validates :description, presence: true
  validates :testIO, presence: true
  validates :code, presence: true

  enum status: [ :empty, :saved, :testing_stub, :testing_model_solution, :finished, :error ]

  def parse_exercise
    # TODO
  end
end
