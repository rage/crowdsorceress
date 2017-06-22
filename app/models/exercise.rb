# frozen_string_literal: true

class Exercise < ApplicationRecord
  belongs_to :assignment
  belongs_to :user

  validates :description, presence: true
  validates :testIO, presence: true
  validates :code, presence: true

  enum status: %i[status_undefined saved testing_stub testing_model_solution finished error]

  def parse_code
    model_solution_parts = self.code.scan((/\/\/ BEGIN SOLUTION\n.*?\n\/\/ END SOLUTION/))

    stub = self.code

    model_solution_parts.each do |part|
      puts 'part: ' + part
      stub = stub.sub(part, '')
      stub = stub
      puts 'stub loopin sisällä: ' + stub
    end

    puts 'stub lopuksi: ' + stub

    model_solution = self.code

  end

  def write_model_solution

  end

  def write_stub

  end
end
