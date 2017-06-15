# frozen_string_literal: true

class ExerciseVerifierJob < ApplicationJob
  require 'test_generator'
  require 'main_class_generator'
  require 'rest-client'
  queue_as :default

  rescue_from(ActiveRecord::RecordNotFound) do |_exception|
    puts 'RECORD NOT FOUND TROLOLOLO'
  end

  def perform(exercise)
    if exercise.is_a? String
      Rails.logger.warn('ExerciseVerifiedJob called with a string! Silently aborting...')
      return
    end
    puts 'EXERCISE ID: ' + exercise.id.to_s
    puts 'Performing! omg'

    # create_tar(exercise)
    send_to_sandbox(exercise)
  end

  def create_tar(exercise)
    create_file('srcfile', exercise)
    create_file('testfile', exercise)

    Minitar.pack(['DoesThisEvenCompile', 'ext/tmc-langs/tmc-langs-cli/target/tmc-langs-cli-0.7.7-SNAPSHOT.jar'],
                 File.open('JavaPackage.tar', 'wb'))
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

  def send_to_sandbox(exercise)
    create_tar(exercise)
    puts 'Sending to sandbox'
    File.open('JavaPackage.tar', 'r') do |tar_file|
      RestClient.post post_url, file: tar_file, notify: 'https://1085f425.ngrok.io/exercises', token: 'KISSA'
    end
    puts 'Sent to sandbox'
  end

  def post_url
    ENV['SANDBOX_BASE_URL'] + '/tasks.json'
  end
end
