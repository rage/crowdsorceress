# frozen_string_literal: true

class ExerciseVerifierJob < ApplicationJob
  require 'test_generator'
  require 'main_class_generator'
  queue_as :default

  rescue_from(ActiveRecord::RecordNotFound) do |_exception|
    puts 'RECORD NOT FOUND TROLOLOLO'
  end

  def perform(exercise)
    puts 'EXERCISE ID: ' + exercise.id.to_s
    puts 'Performing! omg'

    create_tarball(exercise)
  end

  def create_tarball(exercise)
    create_file('srcfile', exercise)
    create_file('testfile', exercise)

    Minitar.pack(['DoesThisEvenCompile', 'ext/tmc-langs/tmc-langs-cli/target/tmc-langs-cli-0.7.7-SNAPSHOT.jar'],
                 Zlib::GzipWriter.new(File.open('JavaPackage' + '.tgz', 'wb')))
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

    File.open(filename, 'w') do |f|
      f.write(generator.generate(exercise))
    end
  end
end
