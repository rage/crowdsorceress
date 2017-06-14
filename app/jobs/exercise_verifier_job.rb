# frozen_string_literal: true

class ExerciseVerifierJob < ApplicationJob
  require 'test_generator'
  require 'main_class_generator'
  queue_as :default

  rescue_from(ActiveRecord::RecordNotFound) do |_exception|
    puts 'RECORD NOT FOUND TROLOLOLO'
  end

  #   before_perform do
  #     puts 'HEIPPA'
  #   end

  def perform(exercise)
    if exercise.is_a? String
      Rails.logger.warn('ExerciseVerifiedJob called with a string! Silently aborting...')
      return
    end
    puts 'EXERCISE ID: ' + exercise.id.to_s
    puts 'Performing! omg'

    create_tarball(exercise)
  end

  def create_tarball(exercise)
    srcfile = create_file('srcfile', exercise)
    testfile = create_file('testfile', exercise)

    Minitar.pack('DoesThisEvenCompile', Zlib::GzipWriter.new(File.open('DoesThisEvenCompile' + '.tgz', 'wb')))
  end

  def create_file(file_type, exercise)
    if file_type == 'srcfile'
      filename = 'DoesThisEvenCompile/src/DoesThisEvenCompile.java'
      generator = MainClassGenerator.new
    end
    if file_type == 'testfile'
      filename = 'DoesThisEvenCompile/test/DoesThisEvenCompileTest.java'
      generator = TestGenerator.new
    end

    file = File.new(filename, 'w+')
    file.close

    File.open(filename, 'w') do |file|
      file.write(generator.generate(exercise))
    end
  end
end
