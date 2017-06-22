# frozen_string_literal: true

class Exercise < ApplicationRecord
  belongs_to :assignment
  belongs_to :user

  validates :description, presence: true
  validates :testIO, presence: true
  validates :code, presence: true

  enum status: %i[status_undefined saved testing_stub testing_model_solution finished error]

  def create_stub
    stub = code
    stub.gsub(/\/\/ BEGIN SOLUTION\n.*?\n\/\/ END SOLUTION/, '')
  end

  def create_file(file_type)
    self_code = code
    stub = create_stub
    model_solution = self_code

    if file_type == 'stubfile'
      filename = 'Stub/src/Stub.java'
      generator = MainClassGenerator.new
      self.code = stub
      write_to_file(filename, generator, self, 'Stub')
    end

    if file_type == 'model_solution_file'
      filename = 'ModelSolution/src/ModelSolution.java'
      generator = MainClassGenerator.new
      self.code = model_solution
      write_to_file(filename, generator, self, 'ModelSolution')
    end

    if file_type == 'testfile'
      filename = 'ModelSolution/test/ModelSolutionTest.java'
      generator = TestGenerator.new
      self.code = self_code
      write_to_file(filename, generator, self, 'ModelSolution')
    end

    self.code = self_code
  end

  def write_to_file(filename, generator, exercise, class_name)
    file = File.new(filename, 'w+')
    file.close

    File.open(filename, 'w') do |f|
      f.write(generator.generate(exercise, class_name))
    end
  end
end
